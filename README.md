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

Default is `Solo Mode`, without the Reviewing process.

#### Enable the Reviewing process
The first step is to disable the  `Solo Mode`
```ruby
    config.solo_mode = false
```
And then uncomment the configures of the `owner` and `reviewers`
```ruby
    config.owner_model = 'User'
    config.owner_method = :current_user
    config.owner_name_method = :name
    config.owner_avatar = ->(owner) { owner.avatar.url }
  
    config.reviewers = -> do
      User.where(is_admin: true).map do |user|
        {
          name: user.name,
          id: user.id,
          type: 'User',
          avatar_url: user.avatar.url,
        }
      end
    end
```

#### Enable the Attachment files
Run the generator to add the **FileUploader** and **FileReader**
```bash
    $ rails g rails_execution:file_upload
```
And then uncomment the file upload
```ruby
  config.file_upload = true
  config.file_uploader = ::RailsExecution::FileUploader
  config.file_reader = ::RailsExecution::FileReader
```
To limit the File types. Default: `.png`, `.gif`, `.jpg`, `.jpeg`, `.pdf`, `.csv`
You can modify the limitation like this
```ruby
  config.acceptable_file_types = {
    '.jpeg': 'image/jpeg',
    '.pdf': 'application/pdf',
    '.csv': ['text/csv', 'text/plain'],
  }
```

#### Control the Permissions
For example with  *[Pundit](https://github.com/varvet/pundit)* authorization.
```ruby
  config.task_creatable = lambda do |user|
    YourPolicy.new(user).creatable?
  end
  config.task_editable = lambda do |task, user|
    YourPolicy.new(user, task).editable?
  end
  config.task_closable = lambda do |task, user|
    YourPolicy.new(user, task).closable?
  end
  config.task_approvable = lambda do |task, user|
    YourPolicy.new(user, task).approvable?
  end
  config.task_executable = lambda do |task, user|
    YourPolicy.new(user, task).executable?
  end
```

#### Setup the Logger
To storage the logfile
```ruby
  config.logging = lambda do |file, task|
    LoggerModel.create!(task: task, file: file)
  end
```
And list the logfiles on Task page
```ruby
  config.logging_files = lambda do |task|
    LoggerModel.where(task: task).map do |log|
      log.file.expiring_url(30.minutes.to_i)
    end
  end
```

#### Others
To change the Per page of the tasks list.
Default value: `20`
```ruby
  config.per_page = 10
```
