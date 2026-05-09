from setuptools import setup
from Cython.Build import cythonize

setup(
    name="main_module",
    ext_modules=cythonize("main.py", language_level="3"),
)