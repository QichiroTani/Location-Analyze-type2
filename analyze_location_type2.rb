# /////////////////////////////////////////////////////////////////////
# |                                                                   |
# |　           ユーザーの移動トレース用URL記号変換パーサー                  |
# |             analyze_location_type2.rb                             |
# |　           Ver.0　β2                                             |
# |　                    製作者　谷　久一郎                              |
# |　           所属:株式会社空色　開発部                                 |
# |　           製作日:2016/11/16                                      |
# |　備考                                                             |
# |　OK SKYから出力されるURLトラッキング情報の内、Locationに対してユーザーの   |
# |　行動パターンを探るための分析を行うスクリプト。                           |
# |　ユーザーが一連の閲覧行動を取ると、cont_flgに1/0のフラクが記録される。      |
# |　この時、閲覧行動の最初または一回のみ閲覧した場合は"0"を、それ以降連続して    |
# |　閲覧した形跡がある場合"1"が記録される。                                |
# |　なお、連続閲覧が行われている間、URLからURLへの移動に一定時間が経過している  |
# |　場合、別の行動と見なし先頭に当たるURLのcont_flgに"0"が割り振られる。      |
# |                                                                  |
# /////////////////////////////////////////////////////////////////////

require 'csv'
require 'time'


location_data = CSV.read('locaton_data.csv', headers: true)

locaton_base_data = Array.new

#レコード整形
location_data.each do |location_set|
  location = Array.new
  location << location_set[2] #uuid
  location << location_set[6] #Location
  location << Time.parse(location_set[0]) #Date
  locaton_base_data << location
end



#-------------------Make Location Traking sets--------------------------------
uuid_tracking_sets = Array.new
uuid_tracking_set = {}


tmp_uuid = ""                                     #一つ前のUUIDをストアする一時変数
tmp_date = locaton_base_data[0][2]                #一つ前の時間をストアする一時変数(一番最初のレコードの時間を初期値としてセット)
#Location情報セット検索ループ
locaton_base_data.each do |data|
  uuid_tracking_set["uid"] = data[0]              #現UUIDを入力
  uuid_tracking_set["1stdate"] = data[2]          #現時間を入力
  uuid_tracking_set["locat_no"] = data[1].to_i    #現URL IDを入力
  uuid_tracking_set["cont_flg"] = 0               #連続閲覧状態を0でセット(連続する場合1/単体又は最初の場合0)


  #時差計算
  time_deffe = uuid_tracking_set["1stdate"] - tmp_date
  days = time_deffe.divmod(24*60*60)
  hours = days[1].divmod(60*60)
  mins = hours[1].divmod(60)

  if tmp_uuid == uuid_tracking_set["uid"] && mins[0] <= 10  #uuidとlocation_uuidが連続で任意の時間(10分)以内の場合
    #アクセスに任意以内の空き時間がある場合別の連続閲覧扱いにする処理
    uuid_tracking_set["cont_flg"] = 1
  else
    tmp_date = uuid_tracking_set["1stdate"]       #時間更新(現時間を初見時間と判定)
    uuid_tracking_set["cont_flg"] = 0             #先頭URLとして0へ変更
  end #uuidとlocation_uuidが合う場合END
  tmp_uuid = data[0]
  uuid_tracking_sets << uuid_tracking_set
  uuid_tracking_set = {}
end #Location情報セット検索ループ END


#書き出し
set_array = []
CSV.open("Location_traking_sets_ver3.csv",'wb') do |csv|
  uuid_tracking_sets.each do |set|
    set_array = set.values
    puts "#{set_array}"
    csv << set_array
  end
end
