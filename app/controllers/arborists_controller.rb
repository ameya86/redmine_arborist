require 'redmine_arborist/rebuilder'

class ArboristsController < ApplicationController
  #before_filter :authorize

  def issue
    result = RedmineArborist::Rebuilder.rebuild!(Issue, params[:id])
    if result
      flash[:notice] = l(:text_arborist_rebuild_success)
    else
      flash[:error] = l(:text_arborist_rebuild_failure)
    end
    redirect_to back_url
  rescue
    flash[:error] = l(:text_arborist_rebuild_failure)
    redirect_to back_url
  end
end
