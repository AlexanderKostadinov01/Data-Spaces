# the idea is to let the user choose providers and consumers in the DS.
# load each provider and consumer on separate threads.
# Each provider sends their data.
# The user chooses a consumer and queries the fedarated catalogue for available data.
# Then the user chooses a provider and start negotiation and data transfer.
# show part of the data and done.

# TODO: create the scripts for all providers and consumers and test them. (3/3)
# TODO: Provide data for each of the providers (2/3)
# TODO: Set up a federated catalogue. (if possible) (100/100%)
# TODO: write the CLI script for the user interaction. (0/100%)
# TODO: record a video and show it to Iva. (0/100%)

import pandas as pd
import subprocess
import json
import os

class CLI:
    def __init__(self):
        self.csv_path = 'edc_participant_properties.csv'
        self.providers, self.consumers = [], []
        self.provider_ports, self.consumer_ports = [], []
        self.extract_participants()
    
    def extract_participants(self):
        print('Running extract participants...')
        df = pd.read_csv(self.csv_path)
        providers = df[df['name'].apply(lambda x: 'provider' in x)]
        providers_ports = [[providers.iloc[i][col] for col in df.columns if 'port' in col] for i in range(len(providers))]
        
        consumers = df[df['name'].apply(lambda x: 'provider' not in x)]
        consumer_ports = [[consumers.iloc[i][col] for col in df.columns if 'port' in col] for i in range(len(consumers))]
        
        
        self.providers = list(map(lambda x: x.replace('provider-', ''), filter(lambda x: 'provider' in x, df['name'])))
        self.consumers = list(map(lambda x: x.replace('consumer-', ''), filter(lambda x: 'provider' not in x, df['name'])))
        self.provider_ports = providers_ports
        self.consumer_ports = consumer_ports
        
        del df
        print('Extract Participants successful!')
    
    def _get_participants(self, ty: bool):
        success = False
        participant_type = 'providers' if ty else 'consumers'
        
        while not success:
            try:
                user_query = input(f'Select {participant_type[:-1]}(s) - {getattr(self, participant_type)}: ')
                user_query = user_query.split()
                
                if len(user_query) == 0:
                    raise KeyError(f'Please select at least one {participant_type[:-1]}')
                
                for item in user_query:
                    if item.lower() not in getattr(self, participant_type):
                        raise KeyError(f'{participant_type[:-1].capitalize()} {item} not found in available {participant_type}')
                success = True
                
            except KeyError as e:
                print(e)
                print('Try again!')
                success = False

        ids = [getattr(self, participant_type).index(item.lower()) for item in user_query]
        ports = [getattr(self, participant_type[:-1] + '_ports')[i] for i in ids]
        
        return user_query, ports
    
    def get_user_input(self):
        self.user_providers, self.user_provider_ports = self._get_participants(True)
        self.user_consumers, self.user_consumer_ports = self._get_participants(False)
    
    def build_gradle_project(self):
        try:
            subprocess.run(
                ["./gradlew", "transfer:transfer-03-consumer-pull:provider-proxy-data-plane:build"],
                check=True
            )
            print("Gradle build completed successfully.")
        except subprocess.CalledProcessError as e:
            print(f"Gradle build failed: {e}")
    
    def _run_p(self, ty: bool):
        participant_type = 'providers' if ty else 'consumers'
        if ty:
            self.build_gradle_project()
        
        for item, port in zip(getattr(self, 'user_' + participant_type), getattr(self, 'user_' + participant_type[:-1] + '_ports')):
            print(f"Running {participant_type[:-1]} {item} on port {port[2]}...")
            try:
                subprocess.run(
                    [f"./scripts/run-{participant_type[:-1]}.sh", item],
                    check=True
                )
            except subprocess.CalledProcessError as e:
                print(f"Failed to run {participant_type[:-1]} {item} on port {port[2]}: {e}")
    
    def run_fc(self):
        try:
            subprocess.run(
                [f"./scripts/run-fc.sh"],
                check=True
            )
        except subprocess.CalledProcessError as e:
            print(f"Failed to run federated catalogue: {e}")
    
    
    def run_participants(self):
        self._run_p(True)
        self._run_p(False)
        self.run_fc()
    
    def create_APC(self):
        fc_inputs = []
        for provider, ports in zip(self.user_providers, self.user_provider_ports):
            try:
                subprocess.run(
                    [f"./scripts/create-asset-policy-contract.sh", provider.lower(),str(ports[1])],
                    check=True
                )
                fc_inputs.extend([provider.lower(), str(ports[1])])
            except subprocess.CalledProcessError as e:
                print(f"Failed to create asset-policy-contract for provider {provider} on port {ports[1]}: {e}")

        try:
            subprocess.run( 
                [f'./scripts/add-participants.sh', fc_inputs],
                check=True
            )
        except subprocess.CalledProcessError as e:
                print(f"Failed to find participants in the federated catalogue: {e}")
            
    
    def get_policies(self):
        with open("extracted_policies.json", "r") as file:
            data = json.load(file)

        return data
    
    def negotiate_and_transfer(self):
        policies = self.get_policies()
        i = 1
        for provider, p_ports in zip(self.user_providers, self.user_provider_ports):
            for consumer, c_ports in zip(self.user_consumers, self.user_consumer_ports):
                json_path = f'transfer/transfer-01-negotiation/resources/negotiate-contract-{provider}-{consumer}.json'
                if not os.path.exists(json_path):
                    continue

                for policy in policies: # to be implemented by another colleague
                    permissions = policy.get("odrl:permission", None)
                    prohibitions = policy.get("odrl:prohibition", None)

                    if permissions is None or prohibitions is None:
                        continue
                    
                    if consumer in prohibitions: # to be implemented by another colleague
                        continue
                    
                    policy_id = policy.get("@id")
                    if not policy_id:
                        continue
                    
                    try:
                        subprocess.run(
                            [f"./scripts/negotiate.sh", consumer.lower(), str(c_ports[1]), provider.lower(), str(policy_id)],
                            check=True
                        )
                        
                        contract_agreement_id = open('contract_agreements.txt').read()
                        self.transfer(provider.lower(), str(p_ports[0]), consumer.lower(), str(c_ports[1]), contract_agreement_id, f'data{i}.json')
                        i += 1
                        
                    except subprocess.CalledProcessError as e:
                        print(f"Failed to negotiate between {consumer} and {provider} on port {c_ports[1]}: {e}")
                    
                
    def transfer(self, provider: str, public_port: str, consumer: str, mgmt_port: str, contract_agreement_id : str, save_file: str):
        subprocess.run('./scripts/transfer.sh', provider, consumer, mgmt_port, contract_agreement_id, public_port, save_file)

    def run(self):
        self.get_user_input()
        self.run_participants()
        self.create_APC()
        self.negotiate_and_transfer()            

def main():
    T = CLI()
    T.run()

if __name__ == '__main__':
    main()