module EasyAWS
  module CloudFormation
    class Template
      class Resource
        class LaunchConfig < Resource
          array_attr :instances, :security_groups
        end
      end
    end
  end
end
