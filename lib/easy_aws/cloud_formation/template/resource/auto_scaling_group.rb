module EasyAWS
  module CloudFormation
    class Template
      class Resource
        class AutoScalingGroup < Resource
          array_attr :availability_zones, :load_balancer_names
        end
      end
    end
  end
end
