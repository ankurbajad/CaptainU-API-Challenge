require 'json'

class SimulationEngine
  SIMULATION_ENGINE_BINARY = configatron.cmd_line.simulation_engine_binary

  def initialize(simulation_id=nil, time_interval, supply_chain_id, simulation_length, current_user)
    @simulation_id = simulation_id
    @supply_chain_id = supply_chain_id
    @time_interval = time_interval
    @simulation_length = simulation_length
    @current_user = current_user
    @simulation = set_simulation
  end

  def start
    ActiveRecord::Base.transaction do
      response = invoke_function
      resp_payload = response
      resp_payload[:simulation_id] = @simulation.id
      resp_payload
    rescue => exception
      raise exception.to_s
    end
  end

  attr_reader :simulation_id, :supply_chain_id, :time_interval, :simulation_length

  private

  def invoke_function
    Rails.logger.info "SimulationEngineCmd::invoke_function function_name=#{SIMULATION_ENGINE_BINARY}"
    cmd = "./bin/#{SIMULATION_ENGINE_BINARY} #{supply_chain_id.to_i} #{time_interval.to_i} #{simulation_length.to_i} #{@simulation.id}"

    Rails.logger.info "SimulationEngineCmd::invoke_function cmd=#{cmd}"
    result = system cmd

    Rails.logger.info "SimulationEngineCmd::invoke_function result=#{result}"
    if result
      {statusCode: 200}
    else
      {statusCode: 500}
    end

  end

  def set_simulation
    if simulation_id.present?
      simulation = Simulation.find(simulation_id)
      simulation.update(user_id: @current_user.id, start_time: Time.now.utc, parameters: "time_interval:#{time_interval}, supply_chain_id: #{supply_chain_id}, simulation_length: #{simulation_length}")
    else
      simulation = Simulation.create(user_id: @current_user.id, start_time: Time.now.utc, parameters: "time_interval:#{time_interval}, supply_chain_id: #{supply_chain_id}, simulation_length: #{simulation_length}" )
    end
    simulation
  end

end

