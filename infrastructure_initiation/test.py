import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from utils import *

# This prints the structure of the project
print(print_tree(r"C:\Users\Alex\Desktop\Project 2"))
