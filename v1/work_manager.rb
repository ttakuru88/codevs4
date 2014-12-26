class WorkManager
  # 指定座標へ移動
  # resouce目指してvillage展開
  # どっか座標目指してbase展開

  attr_accessor :works, :next_id

  def initialize
    self.works = []
    self.next_id = 1
  end

  def sort
    self.works = works.sort_by(&:primary)
  end

  def add(primary, tasks)
    work = Work.new(next_id, primary, tasks)

    self.next_id += 1
    self.works << work
    work
  end

  def primary_work
    available_works[0]
  end

  def available_works
    works.select { |w| !w.do && !w.done }
  end

  def find(work_id)
    self.works.find { |w| w.id == work_id }
  end
end
