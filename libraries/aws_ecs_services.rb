require 'aws_backend'


class AwsEcsService < AwsResourceBase
  name "aws_ecs_service"
  desc "Verifies settings for an ECS cluster"

  example "
    describe aws_ecs_service(cluster_name: 'backup-cluster', service_name: 'backup-service) do
      it { should exist }
    end
  "

  attr_reader :service_arn, :service_name, :cluster_arn,
              :status, :running_count, :cluster_name

  # def initialize(cluster_name:, service_name:)
  def initialize(opts = {})
    super(opts)
    validate_parameters(allow: [:cluster_name], required: [:service_name])

    catch_aws_errors do
      # If no params are passed we attempt to get the 'default' cluster.
      resp = @aws.ecs_client.describe_services(cluster: opts[:cluster_name], services: [opts[:service_name]]).services.first

      return if !resp || resp.empty?

      @status        = resp.status
      @service_arn   = resp.service_arn
      @service_name  = resp.service_name
      @cluster_arn   = resp.cluster_arn
      @running_count = resp.running_count
    end
  end

  def exists?
    !@service_arn.nil?
  end

  def to_s
    "AWS ECS Service #{@service_name}"
  end
end

