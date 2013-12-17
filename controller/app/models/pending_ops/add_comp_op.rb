class AddCompOp < PendingAppOp

  field :gear_id, type: String
  field :comp_spec, type: Hash, default: {}
  field :init_git_url, type: String

  def handle_parallel_results(tag, gear_id, output, status)
    gear = get_gear()
    component_instance = get_component_instance()
    result_io = ResultIO.new
    result_io.parse_output(output, gear)
    component_details = result_io.appInfoIO.string.empty? ? '' : result_io.appInfoIO.string
    result_io.debugIO << "\n\n#{component_instance.cartridge_name}: #{component_details}" unless component_details.blank?
    gear.process_add_component(component_instance, result_io)
  end

  def execute
    gear = get_gear()
    component_instance = get_component_instance()
    result_io = gear.add_component(component_instance, init_git_url)
    result_io
  end

  def rollback
    gear = get_gear()
    component_instance = get_component_instance()
    result_io = gear.remove_component(component_instance)
    result_io
  end

  def isParallelExecutable()
    return true
  end

  def addParallelExecuteJob(handle)
    gear = get_gear()
    unless gear.removed
      component_instance = get_component_instance()
      job = gear.get_add_component_job(component_instance, init_git_url)
      tag = { "op_id" => self._id.to_s }
      RemoteJob.add_parallel_job(handle, tag, gear, job)
    end
  end

  def action_message
    "A gear configure did not complete"
  end
end
