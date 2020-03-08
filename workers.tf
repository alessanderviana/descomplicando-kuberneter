// Linux instance - Ubuntu 16.04
resource "google_compute_instance" "kube-worker" {
 count = 1
 name         = "kube-worker-${count.index + 1}"
 # machine_type = "n1-standard-2"  # 7.5 GB RAM
 machine_type = "n1-standard-1"  # 3.75 GB RAM
 # machine_type = "g1-small"  # 1.7 GB RAM
 zone         = "${var.region}-b"

 tags = [ "kube-worker-${count.index + 1}" ]

 boot_disk {
   initialize_params {
     image = "ubuntu-1804-bionic-v20200218"
     # image = "ubuntu-1904-disco-v20190514"
   }
 }

 network_interface {
   subnetwork = "default"
   access_config { }
 }

 metadata {
   ssh-keys = "${var.user}:${file("${var.pub_key}")}"
 }

 metadata_startup_script = <<SCRIPT
    echo "***** UPGRADE S.O. *****"
    apt-get update -y && apt-get upgrade -y
    echo "***** INSTALLS DOCKER *****"
    curl -fsSL https://get.docker.com/ | bash
    usermod -aG docker ubuntu
    echo "***** INSTALLS DEPENDENCIES *****"
    apt-get update && apt-get install -y apt-transport-https
    echo "***** KUBERNETES REPO AND KEY *****"
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
    echo "***** INSTALLS KUBERNETES *****"
    apt-get update -y && apt-get install -y kubelet kubeadm kubectl
SCRIPT

}
