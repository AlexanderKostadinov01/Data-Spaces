import numpy as np
import json

def create_data(data_type: str, num_examples: int = 500):
    rows = []
    alphabet = [chr(ord('A') + i) for i in range(26)]
    diseases = [
                  "Anemia",
                  "Diabetes",
                  "Pneumonia",
                  "Asthma",
                  "Urinary Tract Infection (UTI)",
                  "Heart Failure",
                  "Migraine",
                  "Epilepsy",
                  "Gastroenteritis",
                  "Stroke"
                ]
    dental_operations = [
                          "No problem",
                          "Tooth extraction",
                          "Root canal treatment",
                          "Dental filling",
                          "Dental crown placement",
                          "Dental implant surgery",
                          "Scaling and root planing",
                        ]
    for _ in range(num_examples):
        i = np.random.randint(1, 4)
        name = ''.join(np.random.choice(alphabet, i))

        if data_type == 'hospital':
            diseases_id = int(np.random.randint(10))
            operation = diseases[diseases_id]
            age = int(np.random.normal(loc=65, scale=10))  # mean=65, std=10
            gender = 'Female' if (diseases_id + i + age) % 2 else 'Male'
        else:
            operation_id = np.random.choice(np.arange(7), p=[0.3, 0.2, 0.1, 0.1, 0.1, 0.1, 0.1])
            operation = dental_operations[int(operation_id)]
            age = max(3, abs(int(np.random.normal(loc=30, scale=25))))  # mean=30, std=25
            gender = 'Female' if (operation_id + i + age) % 2 else 'Male'

        row = {
            "name": str(name),
            "operation": str(operation),
            "age": int(age),
            "gender": str(gender)
        }
        rows.append(row)

    filename = f"data/{data_type}.json"
    with open(filename, "w") as f:
        json.dump(rows, f, indent=2)

    print(f"Saved {num_examples} {data_type} records to {filename}")

if __name__ == '__main__':
    create_data('hospital')
    create_data('dental')