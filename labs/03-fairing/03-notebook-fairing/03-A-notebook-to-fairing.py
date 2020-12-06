#!/usr/bin/env python
# coding: utf-8

# In[1]:


import tensorflow as tf
import os


# In[2]:


mnist = tf.keras.datasets.mnist
(x_train, y_train), (x_test, y_test) = mnist.load_data()


# In[3]:


x_train, x_test = x_train / 255.0, x_test / 255.0

model = tf.keras.models.Sequential([
    tf.keras.layers.Flatten(input_shape=(28, 28)),
    tf.keras.layers.Dense(128, activation='relu'),
    tf.keras.layers.Dropout(0.2),
    tf.keras.layers.Dense(10, activation='softmax')
])

model.compile(
    optimizer='adam',
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)

model.summary()


# In[4]:


print("Training...")

model.fit(
    x_train, y_train, 
    epochs=3, 
    validation_split=0.2 
) 

score = model.evaluate(x_test, y_test, batch_size=128, verbose=0)
print('Test accuracy: ', score[1])

