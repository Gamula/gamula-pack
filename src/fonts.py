import json

FONT_FILE = "../assets/minecraft/font/default.json"
STARTING_UNICODE_CHAR = 2200

def read_font_file(filepath):
    with open(filepath, "r") as file:
        return json.load(file)

if __name__ == "__main__":
    font = read_font_file(FONT_FILE)
    providers = font["providers"]
    used_chars = set()
    for provider in providers:
        chars = provider["chars"]
        for char in chars:
            if not used_chars.add(char):
                print(f"Duplicate char found {provider["file"]}")

    current_char = STARTING_UNICODE_CHAR
    chars = []
    while len(chars) < 50:
        if current_char not in used_chars:
            chars.append(current_char)
        current_char += 1

    print("\n".join([chr(char) for char in chars]))
