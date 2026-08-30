import tensorflow as tf
import numpy as np
import cv2
import os
from sklearn.metrics.pairwise import cosine_similarity
import pickle

class MedicineRecognizer:
    def __init__(self, train_dir=None, input_size=(224, 224), augment=True, augment_multiplier=35, random_seed=42, load_model_path=None):
        self.input_size = input_size
        self.augment = augment
        self.augment_multiplier = augment_multiplier
        self.augment_multiplier_two = augment_multiplier * 2
        self.random_seed = random_seed

        if random_seed is not None:
            np.random.seed(random_seed)
            tf.random.set_seed(random_seed)
        
        self.embedding_model = self._build_embedding_model()

        if load_model_path:
            self.load(load_model_path)

        elif train_dir:
            self.database = self._build_database(train_dir)

    def _build_embedding_model(self):
        base_model = tf.keras.applications.ResNet50(
            weights='imagenet',
            include_top=False,
            input_shape=(224, 224, 3)
        )
        base_model.trainable = False

        inputs = tf.keras.Input(shape=(224, 224, 3))
        x = tf.keras.applications.resnet.preprocess_input(inputs)
        x = base_model(x, training=False)
        x = tf.keras.layers.GlobalAveragePooling2D()(x)
        x = tf.keras.layers.Lambda(lambda t: tf.math.l2_normalize(t, axis=1))(x)

        return tf.keras.Model(inputs, x)
    
    def _augment_image(self, img, augment_multiplier):
        augmented = []

        for _ in range(augment_multiplier):
            aug_img = img.copy()

            if np.random.rand() > 0.3:
                angle = np.random.uniform(-30, 30)
                h, w = aug_img.shape[:2]
                M = cv2.getRotationMatrix2D((w/2, h/2), angle, 1.0)
                aug_img = cv2.warpAffine(aug_img, M, (w, h), borderMode=cv2.BORDER_REFLECT)

            if np.random.rand() > 0.4:
                aug_img = cv2.flip(aug_img, 1)

            if np.random.rand() > 0.7:
                aug_img = cv2.flip(aug_img, 0)

            if np.random.rand() > 0.3:
                brightness = np.random.uniform(0.6, 1.4)
                aug_img = np.clip(aug_img * brightness, 0, 255).astype(np.uint8)

            if np.random.rand() > 0.3:
                contrast = np.random.uniform(0.7, 1.3)
                aug_img = np.clip((aug_img - 127.5) * contrast + 127.5, 0, 255).astype(np.uint8)

            if np.random.rand() > 0.5:
                zoom = np.random.uniform(0.8, 1.2)
                h, w = aug_img.shape[:2]
                new_h, new_w = int(h * zoom), int(w * zoom)
                top = abs(new_h - h) // 2
                left = abs(new_w - w) // 2
                aug_img = aug_img[top:top+new_h, left:left+new_w]
                aug_img = cv2.resize(aug_img, (w, h))

            if np.random.rand() > 0.4:
                tx = np.random.randint(-20, 20)
                ty = np.random.randint(-20, 20)
                h, w = aug_img.shape[:2]
                M = np.float32([[1, 0, tx], [0, 1, ty]])
                aug_img = cv2.warpAffine(aug_img, M, (w, h), borderMode=cv2.BORDER_REFLECT)

            if np.random.rand() > 0.6:
                noise = np.random.normal(0, 5, aug_img.shape).astype(np.int16)
                aug_img = np.clip(aug_img.astype(np.int16) + noise, 0, 255).astype(np.uint8)
            
            augmented.append(aug_img)
        return augmented
    
    def _preprocess(self, image_path):
        img = cv2.imread(image_path)
        if img is None:
            raise ValueError(f"Cannot read image: {image_path}")
        
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        img = cv2.resize(img, self.input_size)
        img = np.expand_dims(img, axis=0)
        return img

    def _build_database(self, train_dir):
        database = {}

        print("Building embedding database")

        for class_name in os.listdir(train_dir):
            class_path = os.path.join(train_dir, class_name)

            if not os.path.isdir(class_path):
                continue

            embeddings = []

            for img_name in os.listdir(class_path):
                if not img_name.lower().endswith(('.jpg', '.png', '.jpeg')):
                    continue

                img_path = os.path.join(class_path, img_name)
                img = self._preprocess(img_path)
                emb = self.embedding_model.predict(img, verbose=0)
                embeddings.append(emb[0])

                if self.augment:
                    if class_name == "lafuzo":
                        augmented_images = self._augment_image(img[0], self.augment_multiplier_two)
                    else:
                        augmented_images = self._augment_image(img[0], self.augment_multiplier)
                    for aug_img in augmented_images:
                        aug_img = np.expand_dims(aug_img, axis=0)
                        aug_emb = self.embedding_model.predict(aug_img, verbose=0)
                        embeddings.append(aug_emb[0])

            database[class_name] = embeddings
            print(f"{class_name}: {len(embeddings)} images")
        
        print("Database ready\n")
        return database
    
    def predict(self, image_path):
        img = self._preprocess(image_path)
        emb = self.embedding_model.predict(img, verbose=0)[0]

        best_score = -2
        best_class = None
        
        for class_name, emb_list in self.database.items():
            for class_emb in emb_list:
                score = cosine_similarity([emb], [class_emb])[0][0]
    
                if score > best_score:
                    best_score = score
                    best_class = class_name
        
        return best_class, float(best_score) 
    
    def evaluate(self, test_dir):
        correct = 0
        total = 0

        for class_name in os.listdir(test_dir):
            class_path = os.path.join(test_dir, class_name)

            if not os.path.isdir(class_path):
                continue

            for img_name in os.listdir(class_path):
                if not img_name.lower().endswith(('.jpg', '.png', '.jpeg')):
                    continue

                img_path = os.path.join(class_path, img_name)

                pred, _ = self.predict(img_path)

                if pred == class_name:
                    correct += 1
                
                total += 1

        accuracy = correct / total if total > 0 else 0
        print(f"Test Accuracy: {accuracy:.4f}")
        return accuracy
    
    def save(self, filepath):
        directory = os.path.dirname(filepath)
        if directory and not os.path.exists(directory):
            os.makedirs(directory)
        
        save_data = {
            'database': self.database,
            'input_size': self.input_size,
            'augment': self.augment,
            'augment_multiplier': self.augment_multiplier,
            'random_seed': self.random_seed
         }

        with open(filepath, 'wb') as f:
            pickle.dump(save_data, f)

        print("model saved")
        print(f"Classes: {len(self.database)}")

    def load(self, filepath):
        if not os.path.exists(filepath):
             raise FileNotFoundError(f"Model file not found: {filepath}")
        
        with open(filepath, 'rb') as f:
             save_data = pickle.load(f)
        
        self.database = save_data['database']
        self.input_size = save_data.get('input_size', (224, 224))
        self.augment = save_data.get('augment', True)
        self.augment_multiplier = save_data.get('augment_multiplier', 35)
        self.random_seed = save_data.get('random_seed', 42)

        print("model loaded")
        print(f"Classes: {len(self.database)}")
        
        for class_name, emb_list in self.database.items():
            print(f"{class_name}: {len(emb_list)} embeddings")
        
    
    # Flutter API
    def _preprocess_image(self, image):
        img = cv2.resize(image, self.input_size)
        img = np.expand_dims(img, axis=0)
        return img
    
    def predict_image(self, image):
        img = self._preprocess_image(image)
        emb = self.embedding_model.predict(img, verbose=0)[0]

        best_score = -2
        best_class = None

        for class_name, emb_list in self.database.items():
            for class_emb in emb_list:
                score = cosine_similarity([emb], [class_emb])[0][0]

                if score > best_score:
                    best_score = score
                    best_class = class_name
        
        return best_class
    
if __name__ == "__main__":
    recognizer = MedicineRecognizer(train_dir="data/train")

    class_name, score = recognizer.predict("data/test/doxaben/doxaben-14.png")
    print(class_name)

    recognizer.evaluate("data/test")

    recognizer.save("models/medicine_recognizer.pkl")