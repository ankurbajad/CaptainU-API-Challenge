require 'aws-sdk-lambda'  # v2: require 'aws-sdk'
require 'json'
require 'os'

class AwsLambda
  ACCESS_KEY_ID = configatron.aws_access_key_id
  SECRET_ACCESS_KEY = configatron.aws_secret_access_key
  AWS_REGION = configatron.aws_region
  LAMBDA_FUNCTION_NAME = configatron.aws_lambda_function
  SIMULATION_ENGINE_BINARY = 'simulation_engine_5'

  def initialize(simulation_id=nil, time_interval, supply_chain_id, simulation_length, current_user)
    @simulation_id = simulation_id
    @supply_chain_id = supply_chain_id
    @time_interval = time_interval
    @simulation_length = simulation_length
    @current_user = current_user
    @simulation = set_simulation
  end

  def start
    Aws.use_bundled_cert!  if OS.windows?
    ActiveRecord::Base.transaction do
      response = invoke_function(payload)
      resp_payload = JSON.parse(response.payload.string)
      resp_payload[:simulation_id] = @simulation.id
      resp_payload
    rescue => exception
      raise exception.to_s
    end
  end

  attr_reader :simulation_id, :supply_chain_id, :time_interval, :simulation_length

  private

  def payload
    JSON.generate({"SimulationID": @simulation.id,"SupplyChainId": supply_chain_id.to_i,"TimeInterval": time_interval.to_i,"SimulationLength": simulation_length.to_i})
  end

  def aws_client
    Rails.logger.info "AwsLambda::aws_client access_key_id=#{ACCESS_KEY_ID} secret_access_key=#{SECRET_ACCESS_KEY} region=#{AWS_REGION}"
    Aws::Lambda::Client.new(
      access_key_id: ACCESS_KEY_ID,
      secret_access_key: SECRET_ACCESS_KEY,
      region: AWS_REGION
    )
  end

  def invoke_function(payload)
    Rails.logger.info "AwsLambda::invoke_function function_name=#{LAMBDA_FUNCTION_NAME} payload=#{payload}"
    cmd = "/usr/bin/aws lambda invoke --function-name #{LAMBDA_FUNCTION_NAME} --payload '#{payload}' response.json"

    Rails.logger.info "AwsLambda::invoke_function cmd=#{cmd}"
    result = system cmd
    
    Rails.logger.info "AwsLambda::invoke_function result=#{result}"
    if result
      {statusCode: 200}
    else
      {statusCode: 500}
    end

  end

  def set_simulation
    if simulation_id.present?
      simulation = @current_user.simulations.find(simulation_id)
      simulation.update(start_time: Time.now.utc, parameters: "time_interval:#{time_interval}, supply_chain_id: #{supply_chain_id}, simulation_length: #{simulation_length}")
    else
      simulation = @current_user.simulations.create(start_time: Time.now.utc, parameters: "time_interval:#{time_interval}, supply_chain_id: #{supply_chain_id}, simulation_length: #{simulation_length}" )
    end
    simulation
  end

end

