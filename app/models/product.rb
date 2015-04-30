# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: products
#
#  id          :integer          not null, primary key
#  name        :string(255)      default(""), not null
#  description :text
#  image       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Product < ActiveRecord::Base
  validates :name, length: {maximum: 96}, presence: true
  validates :description, length: {maximum: 2048}
  has_many :lendings, ->{order ("updated_at DESC")}, dependent: :destroy
  has_many :comments, ->{order ("updated_at ASC")}, dependent: :destroy
  
  mount_uploader :image, ImageUploader
  # タグが管理できるようにする
  acts_as_taggable



  # フォームでbase64_imageというフォーム部品を表示させるために必要
  def base64_image
    return @base64_image
  end
  def base64_image=(file)
    @base64_image = file
  end
  
  # 貸出可能 or 貸出中かを返す
  def status
    if self.lendable?
      "returned"
    else
      "unreturned"
    end
  end
  
  # この備品の累計貸出回数
  def count
    self.lendings.length
  end

  # 借りれるかどうか
  def lendable?
    if latest_lending && latest_lending.status == "unreturned"
      # 借りれない
      false
    else
      # 借りれる
      true
    end
  end

  def latest_lending
    if self.lendings.first
      self.lendings.first
    else
      nil
    end
  end
end
