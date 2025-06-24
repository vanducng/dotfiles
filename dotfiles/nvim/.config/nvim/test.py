import os


def test():
    print(os.environ["PATH"])
    print(os.environ["HOME"])
    print(os.environ["USER"])
    print(os.environ["PWD"])
    print(os.environ["_"])


def add(a: int, b: int) -> int:
    """Add two numbers"""
    print(a, b)
    return a + b
