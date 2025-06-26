import threading
import subprocess

"""
Generate connector jar, so we can run connectors later (provider, consumer)
"""
def build_connector_jar():
    try:
        subprocess.run(['./shell_scripts/build_connector.sh'], check=True)
    except subprocess.CalledProcessError as e:
        print(f'Error while building connector jar: {e}')

def run_connector_consumer():
    try:
        subprocess.run(['./shell_scripts/run_connector_consumer.sh', 'lab'], check=True)
    except subprocess.CalledProcessError as e:
        print(f'Error while running connector consumer: {e}')

def run_connector_provider():
    try:
        subprocess.run(['./shell_scripts/run_connector_provider.sh', 'lab'], check=True)
    except subprocess.CalledProcessError as e:
        print(f'Error while running connector provider: {e}')

def create_asset_policy():
    subprocess.run(["./shell_scripts/create_asset_policy.sh", "lab", "40193"], check=True)

if __name__ == '__main__':
    # build_connector_jar()
    # run_connector_consumer()
    # run_connector_provider()
    create_asset_policy()

    print(2)