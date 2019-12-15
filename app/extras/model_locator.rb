ModelLocator = Struct.new(:model, :params) do

  def locate
    if id_param = params[:"#{model}_id"]
      resource_class.find_by id: id_param
    elsif key_param = params[:"#{model}_key"]
      resource_class.find_by key: key_param
    else
      resource_class.friendly.find_by id: params[:id]
    end
  end

  private

  def resource_class
    @resource_class ||= model.to_s.humanize.constantize
  end
end
