from multiprocessing import cpu_count
from os.path import join, dirname, realpath

PROJ_ROOT = dirname(dirname(realpath(__file__)))

THIRD_PARTY_DIR = join(PROJ_ROOT, "third-party")
CROSSENV_DIR = join(PROJ_ROOT, "cross_venv", "cross")

USABLE_CPUS = str(int(cpu_count()) - 1)
VERSION_FILE = join(PROJ_ROOT, "VERSION")


def get_version():
    with open(VERSION_FILE) as fh:
        version = fh.read().strip()

    return version