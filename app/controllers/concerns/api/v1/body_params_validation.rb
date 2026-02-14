module Api::V1::BodyParamsValidation
  extend ActiveSupport::Concern

  def permit_body_params(permitted_params)
    body_root = request.request_parameters

    root_key = body_root.keys.first
    body_params = body_root[root_key] || {}

    permitted_keys = permitted_params.to_h.keys.map(&:to_s)
    body_keys      = body_params.keys.map(&:to_s)

    unpermitted = body_keys - permitted_keys
    raise ActionController::UnpermittedParameters.new(unpermitted) if unpermitted.any?
  end
end
