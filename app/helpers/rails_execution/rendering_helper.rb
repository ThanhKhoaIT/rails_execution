module RailsExecution::RenderingHelper

  def render_owner_avatar(owner)
    return nil if owner.blank?
    return nil if RailsExecution.configuration.owner_avatar.blank?

    avatar_url = RailsExecution.configuration.owner_avatar(owner)
    return nil if avatar_url.blank?

    image_tag avatar_url, size: '32x32', class: 'bd-placeholder-img flex-shrink-0 me-2 rounded'
  end

end
