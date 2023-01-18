# variable for code build 
variable "FullRepositoryId" {
    description ="github repo id"
    type = string
    default = "https://github.com/vignesh-lirctek/node-js-sample.git"
}
variable "BranchName" {
    description = "github branch name"
    type = string
    default = "main"
} 