import random
from faker import Faker

fake = Faker()

def get_random_name():
    return fake.name()

def get_random_nationality():
    return random.choice(LANGUAGES)

LANGUAGES = [
    ['مرحبا بالعالم', 'Arabic'],
    ['Salam dünya', 'Azerbaijani'],
    ['Hola món', 'Catalan'],
    ['你好，世界', 'Chinese (Simplified)'],
    ['Ahoj světe', 'Czech'],
    ['Hej Verden', 'Danish'],
    ['Hallo Wereld', 'Dutch'],
    ['Hello World', 'English'],
    ['Saluton, Mondo', 'Esperanto'],
    ['Hei maailma', 'Finnish'],
    ['Bonjour le monde', 'French'],
    ['Hallo Welt', 'German'],
    ['Γειά σου Κόσμε', 'Greek'],
    ['שלום עולם', 'Hebrew'],
    ['नमस्ते दुनिया', 'Hindi'],
    ['Helló Világ', 'Hungarian'],
    ['Halo Dunia', 'Indonesian'],
    ['Dia dhuit Domhan', 'Irish'],
    ['Ciao mondo', 'Italian'],
    ['こんにちは世界', 'Japanese'],
    ['안녕, 세상', 'Korean'],
    ['سلام دنیا', 'Persian'],
    ['Witaj świecie', 'Polish'],
    ['Olá Mundo', 'Portuguese'],
    ['Привет, мир', 'Russian'],
    ['Ahoj svet', 'Slovak'],
    ['Hola Mundo', 'Spanish'],
    ['Hej världen', 'Swedish'],
    ['Merhaba Dünya', 'Turkish'],
    ['Привіт, світ', 'Ukrainian'],
]
