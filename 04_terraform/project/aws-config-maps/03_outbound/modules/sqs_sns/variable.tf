variable "aws_account_id" {  type = string }
variable "aws_account_alias" {  type = string }
variable "aws_env" {  type = string }
variable "aws_assume_role_arn" {  type = string }
variable "aws_primary_region" {  type = string }
variable "aws_secondary_region" {  type = string }
variable "aws_vpc_id" {  type = string }
variable "aws_zone_id" {  type = string }
variable "tags" {  type = map(string) }

# --- app ---
variable "app_name" {  type = string }
variable "app_component" {  type = string }
variable "app_env" {  type = string }
variable "app_domain_name" {  type = string }