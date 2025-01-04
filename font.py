import json

FONT_FILE = "./assets/minecraft/font/default.json"

def read_font_file(file_path):
    """
    Reads the Minecraft font file and extracts available characters.

    :param file_path: Path to the default.json font file.
    :return: Set of available characters.
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            font_data = json.load(file)

        # Ensure 'providers' exists in the font data
        if 'providers' not in font_data:
            raise ValueError("Invalid font file: Missing 'providers' key.")

        available_characters = set()

        # Iterate through providers to find characters
        for provider in font_data['providers']:
            if 'chars' in provider:
                for char_set in provider['chars']:
                    if isinstance(char_set, str):  # Add characters as-is
                        available_characters.update(char_set)
                    elif isinstance(char_set, list):  # Handle ranges
                        for char in char_set:
                            if isinstance(char, str):
                                available_characters.update(char)
                            elif isinstance(char, list):
                                start, end = char
                                available_characters.update(chr(c) for c in range(ord(start), ord(end) + 1))
        return available_characters
    except (FileNotFoundError, json.JSONDecodeError, ValueError) as e:
        print(f"Error reading font file: {e}")
        return set()

def find_unused_characters(used_characters, begin_ord=10000, count=20):
    """
    Finds the first `count` unused characters starting from `start_char`.

    :param used_characters: Set of used characters.
    :param start_char: Character to start checking from.
    :param count: Number of unused characters to find.
    :return: List of unused characters.
    """
    unused_characters = []
    current_code = begin_ord

    while len(unused_characters) < count:
        current_char = chr(current_code)
        if current_char not in used_characters:
            unused_characters.append(current_char)
        current_code += 1

    return unused_characters

def main():
    used_characters = read_font_file(FONT_FILE)

    if used_characters:
        unused_characters = find_unused_characters(used_characters)
        print("First 20 unused characters after '∀':")
        print("".join(unused_characters))
    else:
        print("No characters found or invalid font file.")

if __name__ == "__main__":
    main()

