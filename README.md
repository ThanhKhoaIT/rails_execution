# Rails Execution
Rails Execution is an Engine to manage the Rails scripts for migration, cleanup, and fixing the bad data without deployment.
- Supported the Syntax checker
- Supported the Execution logs
- Supported the Reviewing process
- Supported the Attachment files
- Supported the Comments communication
- Supported the Activities tracking


![image](https://user-images.githubusercontent.com/6081795/193129359-fc1e8858-c3e7-4376-be1e-ca453890a98d.png)
![image](https://user-images.githubusercontent.com/6081795/193129792-39176d6e-97fa-4a47-8541-30e7169841cd.png)

## Installation

Add the following line to your **Gemfile**:

```ruby
gem 'rails_execution'
```
Then run `bundle install`


## Getting started

### How to setup
You need to run the generator:
```bash
    $ rails g rails_execution:install
```
And you can change the config in `config/initializers/rails_execution.rb`

Default is `solo_mode` without the Reviewing process

To setup the Reviewing process

#### Enable the Attachment files
Run the generator to add the **FileUploader** and **FileReader**
```bash
    $ rails g rails_execution:file_upload
```
