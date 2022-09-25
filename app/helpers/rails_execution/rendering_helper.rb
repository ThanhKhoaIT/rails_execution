module RailsExecution
  module RenderingHelper

    def render_user_info(user, avatar_size: '40x40')
      content_tag :div, class: 'user-info' do
        concat render_owner_avatar(user, size: avatar_size)
        concat render_owner_name(user)
      end
    end

    def render_owner_avatar(owner, size: '32x32')
      return nil if owner.blank?

      avatar_url = RailsExecution.configuration.owner_avatar.call(owner)
      return nil if avatar_url.blank?

      image_tag avatar_url, size: size, class: 'bd-placeholder-img flex-shrink-0 me-2 rounded'
    end

    def render_owner_name(owner)
      return nil if owner.blank?
      return nil if RailsExecution.configuration.owner_name_method.blank?

      content_tag :span, owner.public_send(RailsExecution.configuration.owner_name_method)
    end

    def render_notification_message(mode, message)
      case mode
      when 'alert'
        content_tag :div, class: 'alert alert-warning align-items-center' do
          concat content_tag(:i, nil, class: 'bi bi-x-octagon mr-2')
          concat content_tag(:span, message, class: 'ms-2')
        end
      when 'notice'
        content_tag :div, class: 'alert alert-success align-items-center' do
          concat content_tag(:i, nil, class: 'bi bi-check-circle mr-2')
          concat content_tag(:span, message, class: 'ms-2')
        end
      end
    end

    def task_reviewed_status(task)
      @task_reviewed_status ||= {}
      @task_reviewed_status[task] ||= task.task_reviews.find_by(owner_id: current_owner&.id)&.status&.inquiry
    end

    def re_page_actions(&block)
      content_for :page_actions do
        content_tag :span, class: 'ms-2' do
          capture(&block)
        end
      end
    end

    def re_card_content(id: nil, &block)
      content_tag :div, id: id, class: 'my-3 p-3 bg-body rounded shadow-sm' do
        capture(&block)
      end
    end

    def re_render_paging(relation)
      render partial: 'rails_execution/shared/paging', locals: { page: relation.re_current_page, total_pages: relation.re_total_pages }
    end

    def re_badge_color(status)
      color = status_to_color(status.to_s.downcase.to_sym)
      content_tag :small, status.to_s.titleize, class: "fw-light badge rounded-pill text-bg-#{color}"
    end

    private

    def status_to_color(text)
      {
        bad: 'danger',
        good: 'success',
        closed: 'danger',
        created: 'primary',
        rejected: 'danger',
        approved: 'success',
        reviewing: 'secondary',
        completed: 'success',
      }[text] || 'secondary'
    end

  end
end
