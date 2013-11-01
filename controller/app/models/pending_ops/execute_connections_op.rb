class ExecuteConnectionsOp < PendingAppOp

  field :sub_pub_info, type: Hash, default: {}

  def execute
    pending_app_op_group.application.execute_connections(sub_pub_info) rescue nil
  end

  def rollback
    pending_app_op_group.application.execute_connections(sub_pub_info) rescue nil
  end

end
