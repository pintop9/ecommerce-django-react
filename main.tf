terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region                   = "il-central-1"
  shared_config_files      = ["/Users/user/.aws/config"]
  shared_credentials_files = ["/Users/user/.aws/credentials"]
  profile                  = "default"
}
resource "aws_ebs_volume" "jenkins_volume" {
  availability_zone = "il-central-1c"
  size              = 8
}
data "aws_vpc" "default" {
  default = true
}


data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
data "aws_security_group" "Jenkins_master" {
  id = "sg-03e037ab416060470"
}
data "aws_security_group" "ubuntu" {
  id = "sg-05cfe8fa65a8a7ae8"
}
data "aws_security_group" "Windows" {
  id = "sg-0602203178c4656fa"
}

resource "aws_instance" "jenkins" {
  ami             = "ami-07c0a4909b86650c0"
  instance_type   = "t3.micro"
  subnet_id       = data.aws_subnets.default.ids[0]
  security_groups = [data.aws_security_group.Jenkins_master.id]
  availability_zone = "il-central-1c"
  key_name      = "aws_tf"

  root_block_device {
    volume_size           = 30
    delete_on_termination = true 
  }

  tags = {
    Name = "jenkins_master"
  }
 
  user_data = <<-EOF
    #!/bin/bash

    service_name="jenkins"

    sudo apt update
    sudo apt install -y git fontconfig openjdk-17-jre docker.io python3.10-venv

    echo "Java and available updates installed"

    sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
      https://pkg.jenkins.io/debian/jenkins.io-2023.key
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" \
      | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

    sudo apt update
    sudo apt install -y jenkins
    sudo usermod -aG docker jenkins

    echo "Jenkins installed successfully..."


  EOF
}

resource "aws_volume_attachment" "jenkins_va" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.jenkins_volume.id
  instance_id = aws_instance.jenkins.id
}

resource "aws_instance" "ubuntu" {
  ami             = "ami-07c0a4909b86650c0"
  instance_type   = "t3.micro"
  subnet_id       = data.aws_subnets.default.ids[0]
  security_groups = [data.aws_security_group.ubuntu.id]
  availability_zone = "il-central-1c"
  key_name      = "aws_tf"

  root_block_device {
    volume_size           = 8
    delete_on_termination = true 
  }

  tags = {
    Name = "my ubuntu"
  }
   user_data = <<-EOF
    #!/bin/bash

    sudo apt update
    sudo apt install -y fontconfig openjdk-17-jre docker.io
  EOF
}
resource "aws_ebs_volume" "ubuntu_volume" {
  availability_zone = "il-central-1c"
  size              = 8
}
resource "aws_volume_attachment" "ubuntu_va" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.ubuntu_volume.id
  instance_id = aws_instance.ubuntu.id
}
resource "aws_instance" "windows" {
  ami             = "ami-0d02677ab01fe699d"
  instance_type   = "t3.micro"
  subnet_id       = data.aws_subnets.default.ids[0]
  security_groups = [data.aws_security_group.Windows.id]
  availability_zone = "il-central-1c"
  key_name      = "aws_tf"

  root_block_device {
    volume_size           = 30
    delete_on_termination = true 
  }

  tags = {
    Name = "my windows"
  }
  
  user_data = <<-EOF
    <powershell>
    # Update the system
    Start-Transcript -Path "C:\install.log"
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
    Install-Module -Name PowerShellGet -Force -AllowClobber
    Install-Module -Name PackageManagement -Force -AllowClobber

    # Install Chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    # Ensure Chocolatey is in the path
    $env:Path += ";$($env:ALLUSERSPROFILE)\chocolatey\bin"

    # Use Chocolatey to install packages
    choco install openjdk17 -y
    
    Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/microsoft/Windows-Containers/Main/helpful_tools/Install-DockerCE/install-docker-ce.ps1" -o install-docker-ce.ps1
    .\install-docker-ce.ps1
    Stop-Transcript
    </powershell>
  EOF

}

resource "aws_ebs_volume" "windows_volume" {
  availability_zone = "il-central-1c"
  size              = 30
}
resource "aws_volume_attachment" "windows_va" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.windows_volume.id
  instance_id = aws_instance.windows.id
}