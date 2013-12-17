class ExposePortOp < PendingAppOp

  field :comp_spec, type: Hash, default: {}
  field :gear_id, type: String

  def isParallelExecutable()
    return true
  end

  def addParallelExecuteJob(handle)
    gear = get_gear()
    unless gear.removed
      component_instance = get_component_instance()
      return if component_instance.is_sparse? and not gear.sparse_carts.include? component_instance._id
      job = gear.get_expose_port_job(component_instance)
      tag = { "expose-ports" => component_instance._id.to_s, "op_id" => self._id.to_s }
      RemoteJob.add_parallel_job(handle, tag, gear, job)
    end
  end

  def handle_parallel_results(tag, gear_id, output, status)
    if status == 0
      result = ResultIO.new(status, output, gear_id)
      component_instance_id = tag["expose-ports"]
      component_instance = application.component_instances.find(component_instance_id)
      component_instance.process_properties(result)
      process_gear = nil
      application.group_instances.each do |gi|
        gi.gears.each do |g|
          if g.uuid.to_s == gear_id
            process_gear = g
            break
          end
        end
        break if process_gear
      end
      application.process_commands(result, component_instance, process_gear)
      nil
    else
      super
    end
  end

end
