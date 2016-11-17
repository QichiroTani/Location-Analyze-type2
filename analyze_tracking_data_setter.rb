# /////////////////////////////////////////////////////////////////////
# |                                                                   |
# |　           ユーザーの移動情報データセット変換システム                   |
# |             analyze_tracking_data_setter.rb                       |
# |　           Ver.0　                                               |
# |　                    製作者　谷　久一郎                              |
# |　           所属:株式会社空色　開発部                                 |
# |　           製作日:2016/11/17                                      |
# |　備考                                                             |
# |　OK SKYから出力されるURLトラッキング情報のから作られたanalyze_location_  |
# |  type2で作られたデータを元に以下のようなデータセットを組み出力する。        |
# | [ID,時差,順路番号,URL_ID]                                           |
# /////////////////////////////////////////////////////////////////////

require 'csv'
require 'time'


location_data = CSV.read('../Location_traking_sets_ver3.csv', headers: true)

tracking_data = []
log_data = {}
log_data[:uuid] = ""
log_data[:time_deff] = 0
log_data[:rout_num] = 0
log_data[:url_id] = ""

#レコード整形
location_data.each do |location_set|
  if location_set[4].to_i == 0
    note_uuid = location_set[0]
    note_unixtime = location_set[1]
    log_data[:time_deff] = 0
  else
  end

  location_base_data << location
end
p location_base_data[0]

puts "読込レコード数 : #{location_base_data.length}件"

#-------------------Make Location Traking sets--------------------------------
puts "パース開始"
uuid_tracking_sets = []
uuid_tracking_set = {}


tmp_uuid = ""                                     #一つ前のUUIDをストアする一時変数
p tmp_date = location_base_data[0][2]                #一つ前の時間をストアする一時変数(一番最初のレコードの時間を初期値としてセット)
#tmp_date = location_base_data[0][3]
#Location情報セット検索ループ
location_base_data.each do |data|
  uuid_tracking_set["uid"] = data[0]              #現UUIDを入力
  uuid_tracking_set["unix_time"] = data[3]        #現時間を入力
  uuid_tracking_set["1stdate"] = data[2]          #現時間を入力
  uuid_tracking_set["locat_no"] = data[1]    #現URL IDを入力
  uuid_tracking_set["cont_flg"] = 0               #連続閲覧状態を0でセット(連続する場合1/単体又は最初の場合0)

  #時差計算
  time_deffe = uuid_tracking_set["1stdate"] - tmp_date
  #time_deffe = uuid_tracking_set["unix_time"] - tmp_date
  days = time_deffe.divmod(24*60*60)
  hours = days[1].divmod(60*60)
  mins = hours[1].divmod(60)

  #if tmp_uuid == uuid_tracking_set["uid"] && mins[0] <= 10  #uuidとlocation_uuidが連続で任意の時間(10分)以内の場合
  if tmp_uuid == uuid_tracking_set["uid"] && mins[0] <= 10
    #アクセスに任意以内の空き時間がある場合別の連続閲覧扱いにする処理
    uuid_tracking_set["cont_flg"] = 1
  else
    tmp_date = uuid_tracking_set["1stdate"]       #時間更新(現時間を初見時間と判定)
    uuid_tracking_set["cont_flg"] = 0             #先頭URLとして0へ変更
  end #uuidとlocation_uuidが連続で任意の時間(10分)以内の場合 END
  tmp_uuid = data[0]
  uuid_tracking_sets << uuid_tracking_set
  uuid_tracking_set = {}
end #Location情報セット検索ループ END

puts "処理終了"
puts "処理したレコード数 : #{uuid_tracking_sets.length}件"

#書き出し
set_array = []
CSV.open("../Location_traking_sets_ver3.csv",'wb') do |csv|
  uuid_tracking_sets.each do |set|
    set_array = set.values
    #puts "#{set_array}"
    csv << set_array
  end
end

puts "Location_traking_sets_ver3.csvへの書出し終了"
