# Implementing Encryption at Rest with AWS KMS Using Terraform

The Nautilus DevOps team is focusing on improving their data security by using AWS KMS. Your task is to create a KMS key and manage the encryption and decryption of a pre-existing sensitive file using the KMS key.

Specific Requirements:

- Create a symmetric KMS key named xfusion-kms-key to manage encryption and decryption.

- Encrypt the provided SensitiveData.txt file (located in /home/bob/terraform), base64 encode the ciphertext, and save the encrypted version as EncryptedData.bin in the /home/bob/terraform directory.

- Try to decrypt the same and verify that the decrypted data matches the original file.

- Create main.tf file (do not create a separate .tf file) to provision a KMS key, encrypt and decrypt the file.

- Create outputs.tf file to output the following:

    - kke_kms_key_name: name of the key created.

Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.


---

# Solution:

- `main.tf`:

```tf
resource "aws_kms_key" "kke_key" {
  description = "Symmetric KMS key for encryption and decryption"
  is_enabled  = true

  tags = {
    Name = "xfusion-kms-key"
  }
}

resource "aws_kms_ciphertext" "kke_encrypt" {
  key_id = aws_kms_key.kke_key.key_id

  plaintext = file("/home/bob/terraform/SensitiveData.txt")
}

resource "terraform_data" "save_encrypted_file" {
  provisioner "local-exec" {
    command = "echo '${aws_kms_ciphertext.kke_encrypt.ciphertext_blob}' > /home/bob/terraform/EncryptedData.bin"
  }

  depends_on = [
    aws_kms_ciphertext.kke_encrypt
  ]
}

# Decrypt and verify in one resource
resource "terraform_data" "decrypt_verify" {
  provisioner "local-exec" {
    command = <<-EOT
      base64 -d /home/bob/terraform/EncryptedData.bin > /tmp/kms-ciphertext.bin

      aws kms decrypt \
        --ciphertext-blob fileb:///tmp/kms-ciphertext.bin \
        --query Plaintext \
        --output text | base64 -d > /tmp/DecryptedData.txt

      diff /home/bob/terraform/SensitiveData.txt /tmp/DecryptedData.txt
    EOT
  }

  depends_on = [
    terraform_data.save_encrypted_file
  ]
}
```

- `outputs.tf`:

```tf
output "kke_kms_key_name" {
  description = "name of the key created"
  value       = aws_kms_key.kke_key.tags["Name"]
}
```


## To verify manually:

```bash
# Base64 decode EncryptedData to a tmp
base64 -d /home/bob/terraform/EncryptedData.bin > /tmp/ciphertext.bi


# Check if there is any diff. If no diff is produced. decrypted file matches the original SensiveData.txt
diff SensitiveData.txt /tmp/DecryptedData.txt
```
