dofile("./Config.lua")
local http = require("socket.http")
local https = require("ssl.https")
local serpent = require("serpent")
local socket = require("socket")
local ltn12 = require("ltn12")
local URL = require("socket.url")
local json = (loadfile "./libs/JSON.lua")()
local redis1 = require("redis")
local redis = redis1.connect("127.0.0.1", 6379)
local Bot_Api = 'https://api.telegram.org/bot' ..token
local offset = 0 
minute = 60
hour = 3600
day = 86400
week = 604800 
MsgTime = os.time() - 5
-----CerNer Company
function is_sudo(msg)
  local var = false
  for v,user in pairs(SUDO_ID) do
    if user == user then
      var = true
    end
  end
  return var
end
function is_Mod(chat_id,user_id)
local var = false
for v,user in pairs(SUDO_ID) do
if user == user_id then
var = true
end
end
local owner = redis:sismember('OwnerList:'..chat_id,user_id)
local hash = redis:sismember('ModList:'..chat_id,user_id)
if hash or owner then
var=  true
end
return var
end
  function is_Owner(chat_id,user_id)
local var = false
for v,user in pairs(SUDO_ID) do
if user== user_id then
var = true
end
end
local hash = redis:sismember('OwnerList:'..chat_id,user_id)
if hash then
var=  true
end
return var
end

local function vardump(value)
print(serpent.block(value, {comment = false}))
end
local function getUpdates()
local response = {}
local success, code, headers, status  = https.request{
url = Bot_Api .. '/getUpdates?timeout=20&limit=1&offset=' .. offset,
method = "POST",
 sink = ltn12.sink.table(response),
  }
local body = table.concat(response or {"no response"})
  if (success == 1) then
return json:decode(body)
  else
return nil, "Request Error"
 end
end
-----------------------
function AnswerInline(inline_query_id, query_id , title , description , text,parse_mode, keyboard)
local results = {{}}
 results[1].id = query_id
results[1].type = 'article'
results[1].description = description
results[1].title = title
results[1].message_text = text
results[1].parse_mode = parse_mode
Rep= Bot_Api .. '/answerInlineQuery?inline_query_id=' .. inline_query_id ..'&results=' .. URL.escape(json:encode(results))..'&parse_mode=&cache_time=' .. 1
if keyboard then
results[1].reply_markup = keyboard
Rep = Bot_Api.. '/answerInlineQuery?inline_query_id=' .. inline_query_id ..'&results=' .. URL.escape(json:encode(results))..'&parse_mode=Markdown&cache_time=' .. 1
end
https.request(Rep)
end
 function downloadFile(file_id, download_path)
if not file_id then return nil, "file_id not specified" end
if not download_path then return nil, "download_path not specified" end
local response = {}
local file_info = getFile(file_id)
local download_file_path = download_path or "downloads/" .. file_info.result.file_path
local download_file = io.open(download_file_path, "w")
if not download_file then return nil, "download_file could not be created"
else
local success, code, headers, status = https.request{
url = "https://api.telegram.org/file/bot" ..token.. "/" .. file_info.result.file_path,
--source = ltn12.source.string(body),
sink = ltn12.sink.file(download_file),
 }
local r = {
 success = true,
download_path = download_file_path,
file = file_info.result
 }
return r
end
end
function es_name(name) 
  if name:match('_') then
   name = name:gsub('_','')
  end
	if name:match('*') then
   name = name:gsub('*','')
  end
	if name:match('`') then
   name = name:gsub('`','')
  end
 return name
end
function SendInline(chat_id, text, keyboard, reply_to_message_id, markdown)
local url = Bot_Api.. '/sendMessage?chat_id=' .. chat_id
if reply_to_message_id then
url = url .. '&reply_to_message_id=' .. reply_to_message_id
end
if markdown == 'md' or markdown == 'markdown' then
url = url..'&parse_mode=Markdown'
elseif markdown == 'html' then
url = url..'&parse_mode=HTML'
end
url = url..'&text='..URL.escape(text)
url = url..'&disable_web_page_preview=true'
url = url..'&reply_markup='..URL.escape(JSON.encode(keyboard))
return https.request(url)
end
function getUserProfilePhotos(user_id, offset, limit)
local Rep = Bot_Api.. '/getUserProfilePhotos?user_id='..user_id
if offset then
Rep = Rep..'&offset='..offset
end
if limit then
if tonumber(limit) > 100 then 
limit = 100 
end
Rep = Rep..'&limit='..limit
end
return https.request(Rep)
end
function run_command(str)
  local cmd = io.popen(str)
  local result = cmd:read('*all')
  cmd:close()
  return result
end
function string:isempty()
  return self == nil or self == ''
end
function Leave(chat_id)
local Rep = Bot_API.. '/leaveChat?chat_id=' .. chat_id
return https.request(Rep)
end
function deletemessages(chat_id, message_id)
local Rep = Bot_Api..'/deletemessage?chat_id='..chat_id..'&message_id='..message_id
return https.request(Rep)
end
function Pin(chat_id, msg_id)
local Rep = Bot_Api..'/pinChatMessage?chat_id='..chat_id..'&message_id='..msg_id
return https.request(Rep)
end
function  changeChatDescription(chat_id, des)
local Rep = Bot_Api..'/setChatDescription?chat_id='..chat_id..'&description='..des
 return https.request(Rep)
end
function unpin(chat_id)
local Rep = Bot_Api..'/unpinChatMessage?chat_id='..chat_id
return https.request(Rep)
end 
function Unban(chat_id, user_id)
local Rep = Bot_Api.. '/unbanChatMember?chat_id=' .. chat_id .. '&user_id=' .. user_id
return https.request(Rep)
end
function CheckChatmember(chat_id, user_id)
local Rep = Bot_Api.. '/unbanChatMember?chat_id=' .. chat_id .. '&user_id=' .. user_id
return https.request(Rep)
end
function KickUser(user_id, chat_id)
local Rep = Bot_Api.. '/kickChatMember?chat_id=' .. chat_id .. '&user_id=' .. user_id
return https.request(Rep)
end
function get_http_file_name(url, headers)
  local file_name = url:match("[^%w]+([%.%w]+)$")
  file_name = file_name or url:match("[^%w]+(%w+)[^%w]+$")
  file_name = file_name or str:random(5)
  local content_type = headers["content-type"]
  local extension = nil
  if content_type then
    extension = mimetype.get_mime_extension(content_type)
  end
  if extension then
    file_name = file_name.."."..extension
  end
  local disposition = headers["content-disposition"]
  if disposition then
    file_name = disposition:match('filename=([^;]+)') or file_name
  end
  return file_name
end
function download_to_file(url, file_name)
  local respbody = {}
  local options = {
    url = url,
    sink = ltn12.sink.table(respbody),
    redirect = true
  }
  local response = nil
  if url:starts('https') then
    options.redirect = false
    response = {https.request(options)}
  else
    response = {http.request(options)}
  end
  local code = response[2]
  local headers = response[3]
  local status = response[4]
  if code ~= 200 then return nil end
  file_name = file_name or get_http_file_name(url, headers)
  local file_path = "data/"..file_name
  file = io.open(file_path, "w+")
  file:write(table.concat(respbody))
  file:close()
  return file_path
end
function sendPhoto(chat_id, file_id, reply_to_message_id, caption)
local Rep = Bot_Api.. '/sendPhoto?chat_id=' .. chat_id .. '&photo=' .. file_id
if reply_to_message_id then
Rep = Rep..'&reply_to_message_id='..reply_to_message_id
end
if caption then
Rep = Rep..'&caption='..URL.escape(caption)
end
return https.request(Rep)
end
function string:input()
if not self:find(' ') then
return false
end
return self:sub(self:find(' ')+1)
end

function getFile(file_id)
local Rep = Bot_Api.. '/getFile?file_id='..file_id
return https.request(Rep)
end
function EditInline( message_id, text, keyboard)
local Rep =  Bot_Api.. '/editMessageText?&inline_message_id='..message_id..'&text=' .. URL.escape(text)
Rep=Rep .. '&parse_mode=Markdown'
if keyboard then
Rep=Rep..'&reply_markup='..URL.escape(json:encode(keyboard))
 end
return https.request(Rep)
 end
function Alert(callback_query_id, text, show_alert)
local Rep = Bot_Api .. '/answerCallbackQuery?callback_query_id=' .. callback_query_id .. '&text=' .. URL.escape(text)
if show_alert then
Rep = Rep..'&show_alert=true'
end
https.request(Rep)
end
function sendText(chat_id, text, reply_to_message_id, markdown)
	local url = Bot_Api .. '/sendMessage?chat_id=' .. chat_id .. '&text=' .. URL.escape(text)
	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end
  if markdown == 'md' or markdown == 'markdown' then
    url = url..'&parse_mode=Markdown'
  elseif markdown == 'html' then
    url = url..'&parse_mode=HTML'
  end
	return https.request(url)
end
---------------------------

function menu(msg,chat_id)
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '🔧 تنظیمات گروه', callback_data = 'management:'..chat_id}
},
{
{text = '📖 اطلاعات گروه', callback_data = 'groupinfo:'..chat_id}
},
{
{text = '🔚 بستن فهرست مدیریتی', callback_data = 'Exit:'..chat_id}
},
{
{text="🆑 کانال تیم ما",url="https://telegram.me/"..ChannelInline..""}
}
}
EditInline(msg.inline_id,'🛡 به بخش تنظیمات و مدیریت خوشآمدید :\n'..msg.user_first..'',keyboard)
end
function management(msg,chat_id)
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '🔩 تنظیمات', callback_data = 'Settings:'..chat_id}
},{
{text =  '⚙ تنظیمات بیشتر', callback_data = 'moresettings:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'Menu:'..chat_id}}}
EditInline(msg.inline_id,'🛡 به بخش تنظیمات خوشآمدید :\n'..msg.user_first..'',keyboard)
end

function setting1(msg,chat_id)
local edited = redis:get('Lock:Edit'..chat_id)
local fwded = redis:get('Lock:Forward:'..chat_id)
local arabiced = redis:get('Lock:Arabic:'..chat_id)
local englished = redis:get('Lock:English:'..chat_id)
local stickered = redis:get('Lock:Sticker:'..chat_id)
local linked = redis:get('Lock:Link'..chat_id)
local taged = redis:get('Lock:Tag:'..chat_id)
local hashtaged = redis:get('Lock:HashTag:'..chat_id)
local inlineed = redis:get('Lock:Inline:'..chat_id)
local video_noteed = redis:get('Lock:Video_note:'..chat_id)
local markdowned = redis:get('Lock:Markdown:'..chat_id)
local edit = (edited == "Warn") and "اخطار" or ((edited == "Kick") and "اخراج" or ((edited == "Mute") and "سکوت" or ((edited == "Enable") and "✔️" or "✖️")))
local fwd = (fwded == "Warn") and "اخطار" or ((fwded == "Kick") and "اخراج" or ((fwded == "Mute") and "سکوت" or ((fwded == "Enable") and "✔️" or "✖️")))
local arabic = (arabiced == "Warn") and "اخطار" or ((arabiced == "Kick") and "اخراج" or ((arabiced == "Mute") and "سکوت" or ((arabiced == "Enable") and "✔️" or "✖️")))
local english = (englished == "Warn") and "اخطار" or ((englished == "Kick") and "اخراج" or ((englished == "Mute") and "سکوت" or ((englished == "Enable") and "✔️" or "✖️")))
local sticker = (stickered == "Warn") and "اخطار" or ((stickered == "Kick") and "اخراج" or ((stickered == "Mute") and "سکوت" or ((stickered == "Enable") and "✔️" or "✖️")))
local link = (linked == "Warn") and "اخطار" or ((linked == "Kick") and "اخراج" or ((linked == "Mute") and "سکوت" or ((linked == "Enable") and "✔️" or "✖️")))
local tag = (taged == "Warn") and "اخطار" or ((taged == "Kick") and "اخراج" or ((taged == "Mute") and "سکوت" or ((taged == "Enable") and "✔️" or "✖️")))
local hashtag = (hashtaged == "Warn") and "اخطار" or ((hashtaged == "Kick") and "اخراج" or ((hashtaged == "Mute") and "سکوت" or ((hashtaged == "Enable") and "✔️" or "✖️")))
local inline = (inlineed == "Warn") and "اخطار" or ((inlineed == "Kick") and "اخراج" or ((inlineed == "Mute") and "سکوت" or ((inlineed == "Enable") and "✔️" or "✖️")))
local video_note = (video_noteed == "Warn") and "اخطار" or ((video_noteed == "Kick") and "اخراج" or ((video_noteed == "Mute") and "سکوت" or ((video_noteed == "Enable") and "✔️" or "✖️")))
local markdown = (markdowned == "Warn") and "اخطار" or ((markdowned == "Kick") and "اخراج" or ((markdowned == "Mute") and "سکوت" or ((markdowned == "Enable") and "✔️" or "✖️")))
if redis:get('Lock:Pin:'..chat_id) then
pin = '✔️'
else
pin = '✖️' 
end
local text = '🛠 تنظیمات گروه  صفحه : 1'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '➰لینک : '..link..'', callback_data = 'lock link:'..chat_id},
{text = '➰ویرایش پیام : '..edit..'', callback_data = 'lock edit:'..chat_id}
},{
{text = '➰فونت : '..markdown..'', callback_data = 'lockmarkdown:'..chat_id},
{text = '➰نام کاربری  : '..tag..'', callback_data = 'locktag:'..chat_id}
},{
{text = '➰تگ(#) : '..hashtag..'', callback_data = 'lockhashtag:'..chat_id},
{text = '➰دکمه شیشه ای : '..inline..'', callback_data = 'lockinline:'..chat_id}
},{
{text = '➰فیلم سلفی : '..video_note..'', callback_data = 'lockvideo_note:'..chat_id},
{text = '➰استیکر : '..sticker..'', callback_data = 'locksticker:'..chat_id}
},{
{text = '➰فوروارد : '..fwd..'', callback_data = 'lockforward:'..chat_id},
{text = '➰فارسی : '..arabic..'', callback_data = 'lockarabic:'..chat_id}
},{
{text = '➰انگلیسی : '..english..'', callback_data = 'lockenglish:'..chat_id},
{text = '➰سنجاق پیام : '..pin..'', callback_data = 'lockpin'..chat_id}
},{
{text = '🔜 صفحه بعدی', callback_data = 'Mutelist:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
function setting2(msg,chat_id)
local txtsed = redis:get('Mute:Text:'..chat_id)
local contacted = redis:get('Mute:Contact:'..chat_id)
local documented = redis:get('Mute:Document:'..chat_id)
local locationed = redis:get('Mute:Location:'..chat_id)
local voiceed = redis:get('Mute:Voice:'..chat_id)
local photoed = redis:get('Mute:Photo:'..chat_id)
local gameed = redis:get('Mute:Game:'..chat_id)
local musiced = redis:get('Mute:Music:'..chat_id)
local gifed = redis:get('Mute:Gif:'..chat_id)
local captioned = redis:get('Mute:Caption:'..chat_id)
local replyed = redis:get('Mute:Reply:'..chat_id)
local txts = (txtsed == "Warn") and "اخطار" or ((txtsed == "Kick") and "اخراج" or ((txtsed == "Mute") and "سکوت" or ((txtsed == "Enable") and "✔️" or "✖️")))
local contact = (contacted == "Warn") and "اخطار" or ((contacted == "Kick") and "اخراج" or ((contacted == "Mute") and "سکوت" or ((contacted == "Enable") and "✔️" or "✖️")))
local document = (documented == "Warn") and "اخطار" or ((documented == "Kick") and "اخراج" or ((documented == "Mute") and "سکوت" or ((documented == "Enable") and "✔️" or "✖️")))
local location = (locationed == "Warn") and "اخطار" or ((locationed == "Kick") and "اخراج" or ((locationed == "Mute") and "سکوت" or ((locationed == "Enable") and "✔️" or "✖️")))
local voice = (voiceed == "Warn") and "اخطار" or ((voiceed == "Kick") and "اخراج" or ((voiceed == "Mute") and "سکوت" or ((voiceed == "Enable") and "✔️" or "✖️")))
local photo = (photoed == "Warn") and "اخطار" or ((photoed == "Kick") and "اخراج" or ((photoed == "Mute") and "سکوت" or ((photoed == "Enable") and "✔️" or "✖️")))
local game = (gameed == "Warn") and "اخطار" or ((gameed == "Kick") and "اخراج" or ((gameed == "Mute") and "سکوت" or ((gameed == "Enable") and "✔️" or "✖️")))
local videoed = redis:get('Mute:Video:'..chat_id)
local video = (videoed == "Warn") and "اخطار" or ((videoed == "Kick") and "اخراج" or ((videoed == "Mute") and "سکوت" or ((videoed == "Enable") and "✔️" or "✖️")))
local music = (musiced == "Warn") and "اخطار" or ((musiced == "Kick") and "اخراج" or ((musiced == "Mute") and "سکوت" or ((musiced == "Enable") and "✔️" or "✖️")))
local gif = (gifed == "Warn") and "اخطار" or ((gifed == "Kick") and "اخراج" or ((gifed == "Mute") and "سکوت" or ((gifed == "Enable") and "✔️" or "✖️")))
local caption = (captioned == "Warn") and "اخطار" or ((captioned == "Kick") and "اخراج" or ((captioned == "Mute") and "سکوت" or ((captioned == "Enable") and "✔️" or "✖️")))
local reply = (replyed == "Warn") and "اخطار" or ((replyed == "Kick") and "اخراج" or ((replyed == "Mute") and "سکوت" or ((replyed == "Enable") and "✔️" or "✖️")))
if redis:get('Lock:TGservise:'..chat_id) then
tgservise = 'فعال'
else
tgservise = 'غیرفعال' 
end
if redis:get('Lock:Bot:'..chat_id) then
bot = 'فعال'
else
bot = 'غیرفعال' 
end
local text = '🛡 تنظیمات گروه  صفحه : 2'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '➰متن : '..txts..'', callback_data = 'mutetext:'..chat_id},
{text = '➰عکس : '..photo..'', callback_data = 'mutephoto:'..chat_id}
},{
{text = '➰مخاطب : '..contact..'', callback_data = 'mutecontact:'..chat_id},
{text = '➰بازی  : '..game..'', callback_data = 'mutegame:'..chat_id}
},{
{text = '➰فایل : '..document..'', callback_data = 'mutedocument:'..chat_id},
{text = '➰فیلم : '..video..'', callback_data = 'mutevideo:'..chat_id}
},{
{text = '➰موقعیت مکانی : '..location..'', callback_data = 'mutelocation:'..chat_id},
{text = '➰آهنگ : '..music..'', callback_data = 'mutemusic:'..chat_id}
},{
{text = '➰ویس : '..voice..'', callback_data = 'mutevoice:'..chat_id},
{text = '➰عنوان : '..caption..'', callback_data = 'mutecaption:'..chat_id}
},{
{text = '➰گیف : '..gif..'', callback_data = 'mutegif:'..chat_id},
{text = '➰ریپلای : '..reply..'', callback_data = 'mutereply:'..chat_id}
},{
{text = '➰ربات : '..bot..'', callback_data = 'lockbot:'..chat_id},
{text = '➰سرویس تلگرام  : '..tgservise..'', callback_data = 'locktgservise:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'Settings:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
function setting3(msg,chat_id)
if redis:get('automuteall'..chat_id) then
auto= 'فعال'
else
auto= 'غیرفعال'
end
if redis:get("Flood:Status:"..chat_id) then
if redis:get("Flood:Status:"..chat_id) == "kickuser" then
Status = 'اخراج کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "muteuser" then
Status = 'سکوت کاربر'
elseif redis:get("Flood:Status:"..chat_id) == "deletemsg"  then
Status = 'حذف پیام'
end
else
Status = 'تنظیم نشده'
end
if redis:get('Lock:Flood:'..chat_id) then
flood = 'فعال'
else
flood = 'غیرفعال'
end
if redis:get('Spam:Lock:'..chat_id) then
spam = 'فعال'
else
spam = 'غیرفعال' 
end
MSG_MAX = 6
if redis:get('Flood:Max:'..chat_id) then
MSG_MAX = redis:get('Flood:Max:'..chat_id)
end
CH_MAX = 200
if redis:get('NUM_CH_MAX:'..chat_id) then
CH_MAX = redis:get('NUM_CH_MAX:'..chat_id)
end
TIME_CHECK = 2
if redis:get('Flood:Time:'..chat_id) then
TIME_CHECK = redis:get('Flood:Time:'..chat_id)
end
warn = 5
if redis:get('Warn:Max:'..chat_id) then
warn = redis:get('Warn:Max:'..chat_id)
end
if redis:get('MuteAll:'..chat_id) then
muteall = 'فعال'
else
muteall = 'غیرفعال' 
end
if redis:get('CheckBot:'..chat_id) then
TD = 'فعال'
else
TD = 'غیرفعال'
end
if redis:get("Lock:Cmd"..chat_id) then
cmd = 'فعال'
else
cmd = 'غیرفعال'
end
local text = '🛡 تنظیمات گروه  صفحه : 4'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '➰ موقعیت پیام مکرر : '..Status..'', callback_data = 'floodstatus:'..chat_id}
},{
{text = '➰ پیام مکرر : '..flood..'', callback_data = 'lockflood:'..chat_id}
},{
{text=' ➰ زمان برسی پیام مکرر : '..tostring(TIME_CHECK)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='TIMEMAXup:'..chat_id},{text='🔻',callback_data='TIMEMAXdown:'..chat_id}
},{
{text=' ➰ تعداد پیام مکرر : '..tostring(MSG_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='MSGMAXup:'..chat_id},{text='🔻',callback_data='MSGMAXdown:'..chat_id}
},{
{text = '➰ هرزنامه : '..spam..'', callback_data = 'lockspam:'..chat_id}
},{
{text=' ➰ تعداد کارکتر(هرزنامه) : '..tostring(CH_MAX)..'',callback_data='cerner'..chat_id}
},{
{text='🔺',callback_data='CHMAXup:'..chat_id},{text='🔻',callback_data='CHMAXdown:'..chat_id}
},{
{text = '🔒 قفل گروه : '..muteall..'', callback_data = 'muteall:'..chat_id}
},{
{text = '🔒 قفل دستورات : '..cmd..'', callback_data = 'lockcommand:'..chat_id}
},{
{text = '🔒 قفل خودکار : '..auto..'', callback_data = 'automuteall:'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'management:'..chat_id}
}
}
EditInline(msg.inline_id,text,keyboard)
end
function locks(msg,chat_id,name,red,cb,back)
	local temp = redis:get(red..chat_id)
	local st = (temp == "Warn") and "اخطار" or ((temp == "Kick") and "اخراج" or ((temp == "Mute") and "سکوت" or ((temp == "Enable") and "فعال" or "غیرفعال")))
	name = name .. " : " .. st
	local keyboard = {}
	keyboard.inline_keyboard = {
		{
			{text = '➰ فعال', callback_data = cb.."enable:"..chat_id},
			{text = '➰ غیر فعال', callback_data = cb.."disable:"..chat_id}
		},
		{
			{text = '➰ اخطار', callback_data = cb.."warn:"..chat_id}
		},
		{
			{text = '➰ سکوت', callback_data = cb.."mute:"..chat_id},
			{text = '➰ اخراج', callback_data = cb.."kick:"..chat_id}
		},
		{
			{text = '🔙 بازگشت', callback_data = back..chat_id}
		}
	}
	EditInline(msg.inline_id,name,keyboard)
end
local function Running()
 while true do
local updates = getUpdates()
if updates and updates.result then
for i = 1, #updates.result do
local msg= updates.result[i]
offset = msg.update_id + 1
if msg.inline_query then
local Company = msg.inline_query
if Company.query:match('-%d+') then
chat_id = '-'..Company.query:match('%d+')
redis:set('chat',chat_id)
if Company.from.id == TD_ID or Company.from.id == Sudoid then
if redis:get('CheckBot:'..chat_id) then
local keyboard = {}
keyboard.inline_keyboard = {{{text = '🔧 تنظیمات گروه', callback_data = 'management:'..chat_id}},{{text= '📖 اطلاعات گروه' ,callback_data = 'groupinfo:'..chat_id}},{{text= '🔚 بستن فهرست مدیریتی' ,callback_data = 'Exit:'..chat_id}},{{text="🆑 کانال تیم ما",url="https://telegram.me/"..ChannelInline..""}}}
AnswerInline(Company.id,'settings','Group settings',chat_id,'🛡 به بخش تنظیمات و مدیریت خوشآمدید','Markdown',keyboard)
else
local keyboard = {}
keyboard.inline_keyboard = {{{text="🆑 کانال تیم ما",url="https://telegram.me/"..ChannelInline..""}}}			
AnswerInline(Company.id,'Not OK','Group Not Found',chat_id,'➰ `کاربر :` _'..Company.from.first_name..'_ `شما دسترسی کافی برای این کار را ندارید`','Markdown',keyboard)
end
end
end
end
if (updates.result) then
for i=1, #updates.result do
 local msg = updates.result[i]
offset = msg.update_id + 1
if msg.inline_query then
local Company = msg.inline_query
if Company.query:match("[Hh][Ee][Ll][Pp]") then
local keyboard = {}
keyboard.inline_keyboard = {{{text="• راهنمای سودو",url="https://t.me/hessibotsnew/4"}},{{text="• راهنمای قفلی",url="https://t.me/hessibotsnew/5"},{text="• راهنمای پاکسازی",url="https://t.me/6"}},{{text="• راهنمای تنظیمی",url="https://t.me/hessibotsnew/7"},{text="• راهنمای مدیریتی",url="https://t.me/hessibotsnew/8"}}}      
AnswerInline(Company.id,'helps','Bot Help',Company.query:match("[Hh][Ee][Ll][Pp]"),'🆘 به فهرست راهنمای ربات خوشآمدید','Markdown',keyboard)
end
end
end
end
if (updates.result) then
for i=1, #updates.result do
 local msg = updates.result[i]
offset = msg.update_id + 1
if msg.inline_query then
local Company = msg.inline_query
if Company.query:match("[Cc][Hh][Aa][Tt][Ss]") then

local page = 0

local keyboard = {}
keyboard.inline_keyboard = {}
local list = redis:smembers('group:')

if #list == 0 then
tt = 'لیست گروهها برای مدیریت خالی میباشد !'
else
tt = '💢 پنل مدیریتی گروه های ربات :'
for k,v in pairs(list) do
local GroupsName = redis:get('StatsGpByName'..v)
local link = redis:get('Link:'..v)
if link then
temp = {{{text=GroupsName,url=link},{text=v,callback_data="Menu:"..v}}}
else
temp = {{{text=GroupsName,callback_data="nolink"..v},{text=v,callback_data="Menu:"..v}}}
end
if(k<6)then
for k,v in pairs(temp) do table.insert(keyboard.inline_keyboard,v) end
else
temp = {{{text= '🔛 صفحه بعدی' ,callback_data = 'ChatsPage:1'}}}
for k,v in pairs(temp) do table.insert(keyboard.inline_keyboard,v) end
break;
end
end
temp = {{{text= '🔚 بستن لیست گروه ها' ,callback_data = 'Exit:-1'}}}
for k,v in pairs(temp) do table.insert(keyboard.inline_keyboard,v) end
end

AnswerInline(Company.id,'chats','Chats',Company.query:match("[Cc][Hh][Aa][Tt][Ss]"),tt,'Markdown',keyboard)
end
end
 end
end
----------Msg.Type-----------------------
if (updates.result) then
for i=1, #updates.result do
 local msg = updates.result[i]
offset = msg.update_id + 1
if msg.message then
local CerNer = msg.message
cerner = CerNer.text
msg.chat_id = CerNer.chat.id
msg.id =  CerNer.message_id
cerner = CerNer.text
msg.user_first = CerNer.from.first_name
msg.user_id = CerNer.from.id
msg.chat_title = CerNer.chat.title

name = es_name(msg.user_first)
first = '['..name..'](tg://user?id='..msg.user_id..')'
if cerner == '(.*)' then
Leave(msg.chat_id)
end
-------------------------------
end 
end
end
-----------------------------------
if cerner then
print(""..cerner.." : Sender : "..(msg.user_id or 'nil').."\nThis is [ TEXT ]")
end
if (updates.result) then
for i=1, #updates.result do
 local msg = updates.result[i]
offset = msg.update_id + 1
if msg.inline_query then
local Company = msg.inline_query
if Company.query:match('%d+') then
local keyboard = {}
keyboard.inline_keyboard = {{{text="🆑 کانال تیم ما",url="https://telegram.me/"..ChannelInline..""}}}
AnswerInline(Company.id,'Click To See User','Click To See User',Company.query:match('%d+'),'[📋 برای دیدن اطلاعات کاربر کلیک کنید](tg://user?id='..Company.query:match('%d+')..')','Markdown',keyboard)
end
end
 end
end
 if (updates.result) then
 for i=1, #updates.result do
 local msg = updates.result[i]
offset = msg.update_id + 1
if msg.inline_query then
local Company = msg.inline_query
if Company.query:match("+(.*)") then
local link = Company.query:match("+(.*)")
AnswerInline(Company.id,'mod','GetLink','Url','[URL]('..link..')','Markdown',nil)
end
end
end
end
if msg.callback_query then
local Company = msg.callback_query
cerner = Company.data
msg.user_first= Company.from.first_name
chat_id = '-'..Company.data:match('(%d+)')
msg.inline_id = Company.inline_message_id
if not is_Mod(chat_id,Company.from.id) then
Alert(Company.id,'➰ کاربر '..msg.user_first..' شما دسترسی کافی ندارید',true)
else
if cerner == 'cerner'..chat_id..'' then
Alert(Company.id,"❗️ داری اشتباه میزنی ヅ")
else
if cerner == 'Menu:'..chat_id..'' then
menu(msg,chat_id)
end
if cerner == 'ChatsPage:'..string.sub(chat_id,2) then
local page = tonumber(string.sub(chat_id,2))
local keyboard = {}
keyboard.inline_keyboard = {}
local list = redis:smembers('group:')
local pages = math.floor(#list / 5)
if #list%5 > 0 then pages = pages + 1 end
pages = pages - 1

if #list == 0 then
tt = 'لیست گروهها برای مدیریت خالی میباشد !'
else
tt = '💢 پنل مدیریتی گروه های ربات :'
for k,v in pairs(list) do
if (k > page*5) and (k < page*5+6) then
local GroupsName = redis:get('StatsGpByName'..v)
local link = redis:get('Link:'..v)
if link then
temp = {{{text=v,callback_data="Menu:"..v},{text=GroupsName,url=link}}}
else
temp = {{{text=v,callback_data="Menu:"..v},{text=GroupsName,callback_data="nolink"..v}}}
end
for k,v in pairs(temp) do table.insert(keyboard.inline_keyboard,v) end
end
end
if page == 0 then
if pages > 0 then
temp = {{{text= '🔛 صفحه بعدی' ,callback_data = 'ChatsPage:1'}}}
for k,v in pairs(temp) do table.insert(keyboard.inline_keyboard,v) end
end
elseif page == pages then
temp = {{{text= 'صفحه قبلی 🔛' ,callback_data = 'ChatsPage:'..(page-1)}}}
for k,v in pairs(temp) do table.insert(keyboard.inline_keyboard,v) end
else 
temp = {{{text= 'صفحه قبلی 🔛' ,callback_data = 'ChatsPage:'..(page-1)},{text= '🔛 صفحه بعدی' ,callback_data = 'ChatsPage:'..(page+1)}}}
for k,v in pairs(temp) do table.insert(keyboard.inline_keyboard,v) end
end
temp = {{{text= '🔚 بستن لیست گروه ها' ,callback_data = 'Exit:-1'}}}
for k,v in pairs(temp) do table.insert(keyboard.inline_keyboard,v) end
end
EditInline(msg.inline_id,tt,keyboard) 
end
if cerner == 'management:'..chat_id then
management(msg,chat_id)
end
if cerner == 'Settings:'..chat_id then
setting1(msg,chat_id)
end
if cerner == 'moresettings:'..chat_id then
setting3(msg,chat_id)
end
if cerner == 'Mutelist:'..chat_id then
setting2(msg,chat_id)
end
if cerner == 'Exit:'..chat_id..'' then
EditInline(msg.inline_id,'🔝 فهرست شیشه ای با موفقیت بسته شد ヅ',keyboard)
end
-------------------------------------
if cerner == 'lock edit:'..chat_id then
	locks(msg,chat_id,'➰ قفل ویرایش پیام','Lock:Edit','lock edit:','Settings:')
end
if cerner == 'lock edit:kick:'..chat_id then
	redis:set('Lock:Edit'..chat_id,"Kick")
	locks(msg,chat_id,'➰ قفل ویرایش پیام','Lock:Edit','lock edit:','Settings:')
end
if cerner == 'lock edit:warn:'..chat_id then
	redis:set('Lock:Edit'..chat_id,"Warn")
	locks(msg,chat_id,'➰ قفل ویرایش پیام','Lock:Edit','lock edit:','Settings:')
end
if cerner == 'lock edit:mute:'..chat_id then
	redis:set('Lock:Edit'..chat_id,"Mute")
	locks(msg,chat_id,'➰ قفل ویرایش پیام','Lock:Edit','lock edit:','Settings:')
end
if cerner == 'lock edit:enable:'..chat_id then
	redis:set('Lock:Edit'..chat_id,"Enable")
	locks(msg,chat_id,'➰ قفل ویرایش پیام','Lock:Edit','lock edit:','Settings:')
end
if cerner == 'lock edit:disable:'..chat_id then
	redis:del('Lock:Edit'..chat_id)
	locks(msg,chat_id,'➰ قفل ویرایش پیام','Lock:Edit','lock edit:','Settings:')
end
-------------------------------------
if cerner == 'lock link:'..chat_id then
	locks(msg,chat_id,'➰ قفل ارسال لینک','Lock:Link','lock link:','Settings:')
end
if cerner == 'lock link:kick:'..chat_id then
	redis:set('Lock:Link'..chat_id,"Kick")
	locks(msg,chat_id,'➰ قفل ارسال لینک','Lock:Link','lock link:','Settings:')
end
if cerner == 'lock link:warn:'..chat_id then
	redis:set('Lock:Link'..chat_id,"Warn")
	locks(msg,chat_id,'➰ قفل ارسال لینک','Lock:Link','lock link:','Settings:')
end
if cerner == 'lock link:mute:'..chat_id then
	redis:set('Lock:Link'..chat_id,"Mute")
	locks(msg,chat_id,'➰ قفل ارسال لینک','Lock:Link','lock link:','Settings:')
end
if cerner == 'lock link:enable:'..chat_id then
	redis:set('Lock:Link'..chat_id,"Enable")
	locks(msg,chat_id,'➰ قفل ارسال لینک','Lock:Link','lock link:','Settings:')
end
if cerner == 'lock link:disable:'..chat_id then
	redis:del('Lock:Link'..chat_id)
	locks(msg,chat_id,'➰ قفل ارسال لینک','Lock:Link','lock link:','Settings:')
end
-------------------------------------
if cerner == 'lockmarkdown:'..chat_id then
	locks(msg,chat_id,'➰ قفل  نشانه گذاری','Lock:Markdown:','lockmarkdown:','Settings:')
end
if cerner == 'lockmarkdown:kick:'..chat_id then
	redis:set('Lock:Markdown:'..chat_id,"Kick")
	locks(msg,chat_id,'➰ قفل  نشانه گذاری','Lock:Markdown:','lockmarkdown:','Settings:')
end
if cerner == 'lockmarkdown:warn:'..chat_id then
	redis:set('Lock:Markdown:'..chat_id,"Warn")
	locks(msg,chat_id,'➰ قفل  نشانه گذاری','Lock:Markdown:','lockmarkdown:','Settings:')
end
if cerner == 'lockmarkdown:mute:'..chat_id then
	redis:set('Lock:Markdown:'..chat_id,"Mute")
	locks(msg,chat_id,'➰ قفل  نشانه گذاری','Lock:Markdown:','lockmarkdown:','Settings:')
end
if cerner == 'lockmarkdown:enable:'..chat_id then
	redis:set('Lock:Markdown:'..chat_id,"Enable")
	locks(msg,chat_id,'➰ قفل  نشانه گذاری','Lock:Markdown:','lockmarkdown:','Settings:')
end
if cerner == 'lockmarkdown:disable:'..chat_id then
	redis:del('Lock:Markdown:'..chat_id)
	locks(msg,chat_id,'➰ قفل  نشانه گذاری','Lock:Markdown:','lockmarkdown:','Settings:')
end
-------------------------------------
if cerner == 'lockforward:'..chat_id then
	locks(msg,chat_id,'➰ قفل فوروارد','Lock:Forward:','lockforward:','Settings:')
end
if cerner == 'lockforward:kick:'..chat_id then
	redis:set('Lock:Forward:'..chat_id,"Kick")
	locks(msg,chat_id,'➰ قفل فوروارد','Lock:Forward:','lockforward:','Settings:')
end
if cerner == 'lockforward:warn:'..chat_id then
	redis:set('Lock:Forward:'..chat_id,"Warn")
	locks(msg,chat_id,'➰ قفل فوروارد','Lock:Forward:','lockforward:','Settings:')
end
if cerner == 'lockforward:mute:'..chat_id then
	redis:set('Lock:Forward:'..chat_id,"Mute")
	locks(msg,chat_id,'➰ قفل فوروارد','Lock:Forward:','lockforward:','Settings:')
end
if cerner == 'lockforward:enable:'..chat_id then
	redis:set('Lock:Forward:'..chat_id,"Enable")
	locks(msg,chat_id,'➰ قفل فوروارد','Lock:Forward:','lockforward:','Settings:')
end
if cerner == 'lockforward:disable:'..chat_id then
	redis:del('Lock:Forward:'..chat_id)
	locks(msg,chat_id,'➰ قفل فوروارد','Lock:Forward:','lockforward:','Settings:')
end
-------------------------------------
if cerner == 'lockarabic:'..chat_id then
	locks(msg,chat_id,'➰ قفل عربی','Lock:Arabic:','lockarabic:','Settings:')
end
if cerner == 'lockarabic:kick:'..chat_id then
	redis:set('Lock:Arabic:'..chat_id,"Kick")
	locks(msg,chat_id,'➰ قفل عربی','Lock:Arabic:','lockarabic:','Settings:')
end
if cerner == 'lockarabic:warn:'..chat_id then
	redis:set('Lock:Arabic:'..chat_id,"Warn")
	locks(msg,chat_id,'➰ قفل عربی','Lock:Arabic:','lockarabic:','Settings:')
end
if cerner == 'lockarabic:mute:'..chat_id then
	redis:set('Lock:Arabic:'..chat_id,"Mute")
	locks(msg,chat_id,'➰ قفل عربی','Lock:Arabic:','lockarabic:','Settings:')
end
if cerner == 'lockarabic:enable:'..chat_id then
	redis:set('Lock:Arabic:'..chat_id,"Enable")
	locks(msg,chat_id,'➰ قفل عربی','Lock:Arabic:','lockarabic:','Settings:')
end
if cerner == 'lockarabic:disable:'..chat_id then
	redis:del('Lock:Arabic:'..chat_id)
	locks(msg,chat_id,'➰ قفل عربی','Lock:Arabic:','lockarabic:','Settings:')
end
-------------------------------------
if cerner == 'lockenglish:'..chat_id then
	locks(msg,chat_id,'➰ قفل انگلیسی','Lock:English:','lockenglish:','Settings:')
end
if cerner == 'lockenglish:kick:'..chat_id then
	redis:set('Lock:English:'..chat_id,"Kick")
	locks(msg,chat_id,'➰ قفل انگلیسی','Lock:English:','lockenglish:','Settings:')
end
if cerner == 'lockenglish:warn:'..chat_id then
	redis:set('Lock:English:'..chat_id,"Warn")
	locks(msg,chat_id,'➰ قفل انگلیسی','Lock:English:','lockenglish:','Settings:')
end
if cerner == 'lockenglish:mute:'..chat_id then
	redis:set('Lock:English:'..chat_id,"Mute")
	locks(msg,chat_id,'➰ قفل انگلیسی','Lock:English:','lockenglish:','Settings:')
end
if cerner == 'lockenglish:enable:'..chat_id then
	redis:set('Lock:English:'..chat_id,"Enable")
	locks(msg,chat_id,'➰ قفل انگلیسی','Lock:English:','lockenglish:','Settings:')
end
if cerner == 'lockenglish:disable:'..chat_id then
	redis:del('Lock:English:'..chat_id)
	locks(msg,chat_id,'➰ قفل انگلیسی','Lock:English:','lockenglish:','Settings:')
end
-------------------------------------
if cerner == 'locktgservise:'..chat_id then
if redis:get('Lock:TGservise:'..chat_id) then
redis:del('Lock:TGservise:'..chat_id)
Alert(Company.id,"➰ قفل  حدف پیام ورود خروج غیرفعال شد ")
else
redis:set('Lock:TGservise:'..chat_id,true)
Alert(Company.id,"➰ قفل  حدف پیام ورود خروج فعال شد")
end
setting2(msg,chat_id)
end
-------------------------------------
if cerner == 'locksticker:'..chat_id then
	locks(msg,chat_id,'➰ قفل استیکر','Lock:Sticker:','locksticker:','Settings:')
end
if cerner == 'locksticker:kick:'..chat_id then
	redis:set('Lock:Sticker:'..chat_id,"Kick")
	locks(msg,chat_id,'➰ قفل استیکر','Lock:Sticker:','locksticker:','Settings:')
end
if cerner == 'locksticker:warn:'..chat_id then
	redis:set('Lock:Sticker:'..chat_id,"Warn")
	locks(msg,chat_id,'➰ قفل استیکر','Lock:Sticker:','locksticker:','Settings:')
end
if cerner == 'locksticker:mute:'..chat_id then
	redis:set('Lock:Sticker:'..chat_id,"Mute")
	locks(msg,chat_id,'➰ قفل استیکر','Lock:Sticker:','locksticker:','Settings:')
end
if cerner == 'locksticker:enable:'..chat_id then
	redis:set('Lock:Sticker:'..chat_id,"Enable")
	locks(msg,chat_id,'➰ قفل استیکر','Lock:Sticker:','locksticker:','Settings:')
end
if cerner == 'locksticker:disable:'..chat_id then
	redis:del('Lock:Sticker:'..chat_id)
	locks(msg,chat_id,'➰ قفل استیکر','Lock:Sticker:','locksticker:','Settings:')
end
-------------------------------------
if cerner == 'mutetext:'..chat_id then
	locks(msg,chat_id,'➰ قفل متن','Mute:Text:','mutetext:','Mutelist:')
end
if cerner == 'mutetext:kick:'..chat_id then
	redis:set('Mute:Text:'..chat_id,"Kick")
	locks(msg,chat_id,'➰ قفل متن','Mute:Text:','mutetext:','Mutelist:')
end
if cerner == 'mutetext:warn:'..chat_id then
	redis:set('Mute:Text:'..chat_id,"Warn")
	locks(msg,chat_id,'➰ قفل متن','Mute:Text:','mutetext:','Mutelist:')
end
if cerner == 'mutetext:mute:'..chat_id then
	redis:set('Mute:Text:'..chat_id,"Mute")
	locks(msg,chat_id,'➰ قفل متن','Mute:Text:','mutetext:','Mutelist:')
end
if cerner == 'mutetext:enable:'..chat_id then
	redis:set('Mute:Text:'..chat_id,"Enable")
	locks(msg,chat_id,'➰ قفل متن','Mute:Text:','mutetext:','Mutelist:')
end
if cerner == 'mutetext:disable:'..chat_id then
	redis:del('Mute:Text:'..chat_id)
	locks(msg,chat_id,'➰ قفل متن','Mute:Text:','mutetext:','Mutelist:')
end
-------------------------------------
if cerner == 'mutecontact:'..chat_id then
	locks(msg,chat_id,'➰ قفل مخاطب','Mute:Contact:','mutecontact:','Mutelist:')
end
if cerner == 'mutecontact:kick:'..chat_id then
	redis:set('Mute:Contact:'..chat_id,"Kick")
	locks(msg,chat_id,'➰ قفل مخاطب','Mute:Contact:','mutecontact:','Mutelist:')
end
if cerner == 'mutecontact:warn:'..chat_id then
	redis:set('Mute:Contact:'..chat_id,"Warn")
	locks(msg,chat_id,'➰ قفل مخاطب','Mute:Contact:','mutecontact:','Mutelist:')
end
if cerner == 'mutecontact:mute:'..chat_id then
	redis:set('Mute:Contact:'..chat_id,"Mute")
	locks(msg,chat_id,'➰ قفل مخاطب','Mute:Contact:','mutecontact:','Mutelist:')
end
if cerner == 'mutecontact:enable:'..chat_id then
	redis:set('Mute:Contact:'..chat_id,"Enable")
	locks(msg,chat_id,'➰ قفل مخاطب','Mute:Contact:','mutecontact:','Mutelist:')
end
if cerner == 'mutecontact:disable:'..chat_id then
	redis:del('Mute:Contact:'..chat_id)
	locks(msg,chat_id,'➰ قفل مخاطب','Mute:Contact:','mutecontact:','Mutelist:')
end
-------------------------------------
if cerner == 'mutegame:'..chat_id then
	locks(msg,chat_id,'➰ قفل بازی','Mute:Game:','mutegame:','Mutelist:')
end
if cerner == 'mutegame:kick:'..chat_id then
	redis:set('Mute:Game:'..chat_id,"Kick")
	locks(msg,chat_id,'➰ قفل بازی','Mute:Game:','mutegame:','Mutelist:')
end
if cerner == 'mutegame:warn:'..chat_id then
	redis:set('Mute:Game:'..chat_id,"Warn")
	locks(msg,chat_id,'➰ قفل بازی','Mute:Game:','mutegame:','Mutelist:')
end
if cerner == 'mutegame:mute:'..chat_id then
	redis:set('Mute:Game:'..chat_id,"Mute")
	locks(msg,chat_id,'➰ قفل بازی','Mute:Game:','mutegame:','Mutelist:')
end
if cerner == 'mutegame:enable:'..chat_id then
	redis:set('Mute:Game:'..chat_id,"Enable")
	locks(msg,chat_id,'➰ قفل بازی','Mute:Game:','mutegame:','Mutelist:')
end
if cerner == 'mutegame:disable:'..chat_id then
	redis:del('Mute:Game:'..chat_id)
	locks(msg,chat_id,'➰ قفل بازی','Mute:Game:','mutegame:','Mutelist:')
end
------------------------------------- 
if cerner == 'mutephoto:'..chat_id then
	locks(msg,chat_id,'➰ قفل عکس','Mute:Photo:','mutephoto:','Mutelist:')
end
if cerner == 'mutephoto:kick:'..chat_id then
	redis:set('Mute:Photo:'..chat_id,"Kick")
	locks(msg,chat_id,'➰ قفل عکس','Mute:Photo:','mutephoto:','Mutelist:')
end
if cerner == 'mutephoto:warn:'..chat_id then
	redis:set('Mute:Photo:'..chat_id,"Warn")
	locks(msg,chat_id,'➰ قفل عکس','Mute:Photo:','mutephoto:','Mutelist:')
end
if cerner == 'mutephoto:mute:'..chat_id then
	redis:set('Mute:Photo:'..chat_id,"Mute")
	locks(msg,chat_id,'➰ قفل عکس','Mute:Photo:','mutephoto:','Mutelist:')
end
if cerner == 'mutephoto:enable:'..chat_id then
	redis:set('Mute:Photo:'..chat_id,"Enable")
	locks(msg,chat_id,'➰ قفل عکس','Mute:Photo:','mutephoto:','Mutelist:')
end
if cerner == 'mutephoto:disable:'..chat_id then
	redis:del('Mute:Photo:'..chat_id)
	locks(msg,chat_id,'➰ قفل عکس','Mute:Photo:','mutephoto:','Mutelist:')
end
-------------------------------------
if cerner == 'mutedocument:'..chat_id then
	locks(msg,chat_id,'➰ قفل فایل','Mute:Document:','mutedocument:','Mutelist:')
end
if cerner == 'mutedocument:kick:'..chat_id then
	redis:set('Mute:Document:'..chat_id,"Kick")
	locks(msg,chat_id,'➰ قفل فایل','Mute:Document:','mutedocument:','Mutelist:')
end
if cerner == 'mutedocument:warn:'..chat_id then
	redis:set('Mute:Document:'..chat_id,"Warn")
	locks(msg,chat_id,'➰ قفل فایل','Mute:Document:','mutedocument:','Mutelist:')
end
if cerner == 'mutedocument:mute:'..chat_id then
	redis:set('Mute:Document:'..chat_id,"Mute")
	locks(msg,chat_id,'➰ قفل فایل','Mute:Document:','mutedocument:','Mutelist:')
end
if cerner == 'mutedocument:enable:'..chat_id then
	redis:set('Mute:Document:'..chat_id,"Enable")
	locks(msg,chat_id,'➰ قفل فایل','Mute:Document:','mutedocument:','Mutelist:')
end
if cerner == 'mutedocument:disable:'..chat_id then
	redis:del('Mute:Document:'..chat_id)
	locks(msg,chat_id,'➰ قفل فایل','Mute:Document:','mutedocument:','Mutelist:')
end
-------------------------------------
if cerner == 'mutevideo:'..chat_id then
	locks(msg,chat_id,'➰ قفل فیلم','Mute:Video:','mutevideo:','Mutelist:')
end
if cerner == 'mutevideo:kick:'..chat_id then
	redis:set('Mute:Video:'..chat_id,"Kick")
	locks(msg,chat_id,'➰ قفل فیلم','Mute:Video:','mutevideo:','Mutelist:')
end
if cerner == 'mutevideo:warn:'..chat_id then
	redis:set('Mute:Video:'..chat_id,"Warn")
	locks(msg,chat_id,'➰ قفل فیلم','Mute:Video:','mutevideo:','Mutelist:')
end
if cerner == 'mutevideo:mute:'..chat_id then
	redis:set('Mute:Video:'..chat_id,"Mute")
	locks(msg,chat_id,'➰ قفل فیلم','Mute:Video:','mutevideo:','Mutelist:')
end
if cerner == 'mutevideo:enable:'..chat_id then
	redis:set('Mute:Video:'..chat_id,"Enable")
	locks(msg,chat_id,'➰ قفل فیلم','Mute:Video:','mutevideo:','Mutelist:')
end
if cerner == 'mutevideo:disable:'..chat_id then
	redis:del('Mute:Video:'..chat_id)
	locks(msg,chat_id,'➰ قفل فیلم','Mute:Video:','mutevideo:','Mutelist:')
end
-------------------------------------
if cerner == 'mutelocation:'..chat_id then
	locks(msg,chat_id,'➰ قفل موقیت مکانی','Mute:Location:','mutelocation:','Mutelist:')
end
if cerner == 'mutelocation:kick:'..chat_id then
	redis:set('Mute:Location:'..chat_id,"Kick")
	locks(msg,chat_id,'➰ قفل موقیت مکانی','Mute:Location:','mutelocation:','Mutelist:')
end
if cerner == 'mutelocation:warn:'..chat_id then
	redis:set('Mute:Location:'..chat_id,"Warn")
	locks(msg,chat_id,'➰ قفل موقیت مکانی','Mute:Location:','mutelocation:','Mutelist:')
end
if cerner == 'mutelocation:mute:'..chat_id then
	redis:set('Mute:Location:'..chat_id,"Mute")
	locks(msg,chat_id,'➰ قفل موقیت مکانی','Mute:Location:','mutelocation:','Mutelist:')
end
if cerner == 'mutelocation:enable:'..chat_id then
	redis:set('Mute:Location:'..chat_id,"Enable")
	locks(msg,chat_id,'➰ قفل موقیت مکانی','Mute:Location:','mutelocation:','Mutelist:')
end
if cerner == 'mutelocation:disable:'..chat_id then
	redis:del('Mute:Location:'..chat_id)
	locks(msg,chat_id,'➰ قفل موقیت مکانی','Mute:Location:','mutelocation:','Mutelist:')
end
-------------------------------------
if cerner == 'mutemusic:'..chat_id then
	locks(msg,chat_id,'➰ قفل آهنگ','Mute:Music:','mutemusic:','Mutelist:')
end
if cerner == 'mutemusic:kick:'..chat_id then
	redis:set('Mute:Music:'..chat_id,"Kick")
	locks(msg,chat_id,'➰ قفل آهنگ','Mute:Music:','mutemusic:','Mutelist:')
end
if cerner == 'mutemusic:warn:'..chat_id then
	redis:set('Mute:Music:'..chat_id,"Warn")
	locks(msg,chat_id,'➰ قفل آهنگ','Mute:Music:','mutemusic:','Mutelist:')
end
if cerner == 'mutemusic:mute:'..chat_id then
	redis:set('Mute:Music:'..chat_id,"Mute")
	locks(msg,chat_id,'➰ قفل آهنگ','Mute:Music:','mutemusic:','Mutelist:')
end
if cerner == 'mutemusic:enable:'..chat_id then
	redis:set('Mute:Music:'..chat_id,"Enable")
	locks(msg,chat_id,'➰ قفل آهنگ','Mute:Music:','mutemusic:','Mutelist:')
end
if cerner == 'mutemusic:disable:'..chat_id then
	redis:del('Mute:Music:'..chat_id)
	locks(msg,chat_id,'➰ قفل آهنگ','Mute:Music:','mutemusic:','Mutelist:')
end
-------------------------------------
if cerner == 'mutevoice:'..chat_id then
	locks(msg,chat_id,'➰ قفل ویس','Mute:Voice:','mutevoice:','Mutelist:')
end
if cerner == 'mutevoice:kick:'..chat_id then
	redis:set('Mute:Voice:'..chat_id,"Kick")
	locks(msg,chat_id,'➰ قفل ویس','Mute:Voice:','mutevoice:','Mutelist:')
end
if cerner == 'mutevoice:warn:'..chat_id then
	redis:set('Mute:Voice:'..chat_id,"Warn")
	locks(msg,chat_id,'➰ قفل ویس','Mute:Voice:','mutevoice:','Mutelist:')
end
if cerner == 'mutevoice:mute:'..chat_id then
	redis:set('Mute:Voice:'..chat_id,"Mute")
	locks(msg,chat_id,'➰ قفل ویس','Mute:Voice:','mutevoice:','Mutelist:')
end
if cerner == 'mutevoice:enable:'..chat_id then
	redis:set('Mute:Voice:'..chat_id,"Enable")
	locks(msg,chat_id,'➰ قفل ویس','Mute:Voice:','mutevoice:','Mutelist:')
end
if cerner == 'mutevoice:disable:'..chat_id then
	redis:del('Mute:Voice:'..chat_id)
	locks(msg,chat_id,'➰ قفل ویس','Mute:Voice:','mutevoice:','Mutelist:')
end
-------------------------------------
if cerner == 'mutegif:'..chat_id then
	locks(msg,chat_id,'➰ قفل گیف','Mute:Gif:','mutegif:','Mutelist:')
end
if cerner == 'mutegif:kick:'..chat_id then
	redis:set('Mute:Gif:'..chat_id,"Kick")
	locks(msg,chat_id,'➰ قفل گیف','Mute:Gif:','mutegif:','Mutelist:')
end
if cerner == 'mutegif:warn:'..chat_id then
	redis:set('Mute:Gif:'..chat_id,"Warn")
	locks(msg,chat_id,'➰ قفل گیف','Mute:Gif:','mutegif:','Mutelist:')
end
if cerner == 'mutegif:mute:'..chat_id then
	redis:set('Mute:Gif:'..chat_id,"Mute")
	locks(msg,chat_id,'➰ قفل گیف','Mute:Gif:','mutegif:','Mutelist:')
end
if cerner == 'mutegif:enable:'..chat_id then
	redis:set('Mute:Gif:'..chat_id,"Enable")
	locks(msg,chat_id,'➰ قفل گیف','Mute:Gif:','mutegif:','Mutelist:')
end
if cerner == 'mutegif:disable:'..chat_id then
	redis:del('Mute:Gif:'..chat_id)
	locks(msg,chat_id,'➰ قفل گیف','Mute:Gif:','mutegif:','Mutelist:')
end
-------------------------------------
if cerner == 'mutereply:'..chat_id then
	locks(msg,chat_id,'➰ قفل ریپلی','Mute:Reply:','mutereply:','Mutelist:')
end
if cerner == 'mutereply:kick:'..chat_id then
	redis:set('Mute:Reply:'..chat_id,"Kick")
	locks(msg,chat_id,'➰ قفل ریپلی','Mute:Reply:','mutereply:','Mutelist:')
end
if cerner == 'mutereply:warn:'..chat_id then
	redis:set('Mute:Reply:'..chat_id,"Warn")
	locks(msg,chat_id,'➰ قفل ریپلی','Mute:Reply:','mutereply:','Mutelist:')
end
if cerner == 'mutereply:mute:'..chat_id then
	redis:set('Mute:Reply:'..chat_id,"Mute")
	locks(msg,chat_id,'➰ قفل ریپلی','Mute:Reply:','mutereply:','Mutelist:')
end
if cerner == 'mutereply:enable:'..chat_id then
	redis:set('Mute:Reply:'..chat_id,"Enable")
	locks(msg,chat_id,'➰ قفل ریپلی','Mute:Reply:','mutereply:','Mutelist:')
end
if cerner == 'mutereply:disable:'..chat_id then
	redis:del('Mute:Reply:'..chat_id)
	locks(msg,chat_id,'➰ قفل ریپلی','Mute:Reply:','mutereply:','Mutelist:')
end
-------------------------------------
if cerner == 'mutecaption:'..chat_id then
	locks(msg,chat_id,'➰ قفل رسانه','Mute:Caption:','mutecaption:','Mutelist:')
end
if cerner == 'mutecaption:kick:'..chat_id then
	redis:set('Mute:Caption:'..chat_id,"Kick")
	locks(msg,chat_id,'➰ قفل رسانه','Mute:Caption:','mutecaption:','Mutelist:')
end
if cerner == 'mutecaption:warn:'..chat_id then
	redis:set('Mute:Caption:'..chat_id,"Warn")
	locks(msg,chat_id,'➰ قفل رسانه','Mute:Caption:','mutecaption:','Mutelist:')
end
if cerner == 'mutecaption:mute:'..chat_id then
	redis:set('Mute:Caption:'..chat_id,"Mute")
	locks(msg,chat_id,'➰ قفل رسانه','Mute:Caption:','mutecaption:','Mutelist:')
end
if cerner == 'mutecaption:enable:'..chat_id then
	redis:set('Mute:Caption:'..chat_id,"Enable")
	locks(msg,chat_id,'➰ قفل رسانه','Mute:Caption:','mutecaption:','Mutelist:')
end
if cerner == 'mutecaption:disable:'..chat_id then
	redis:del('Mute:Caption:'..chat_id)
	locks(msg,chat_id,'➰ قفل رسانه','Mute:Caption:','mutecaption:','Mutelist:')
end
----------------------------------------
if cerner == 'locktag:'..chat_id then
	locks(msg,chat_id,'➰ قفل استیکر','Lock:Tag:','locktag:','Settings:')
end
if cerner == 'locktag:kick:'..chat_id then
	redis:set('Lock:Tag:'..chat_id,"Kick")
	locks(msg,chat_id,'➰ قفل تگ','Lock:Tag:','locktag:','Settings:')
end
if cerner == 'locktag:warn:'..chat_id then
	redis:set('Lock:Tag:'..chat_id,"Warn")
	locks(msg,chat_id,'➰ قفل تگ','Lock:Tag:','locktag:','Settings:')
end
if cerner == 'locktag:mute:'..chat_id then
	redis:set('Lock:Tag:'..chat_id,"Mute")
	locks(msg,chat_id,'➰ قفل تگ','Lock:Tag:','locktag:','Settings:')
end
if cerner == 'locktag:enable:'..chat_id then
	redis:set('Lock:Tag:'..chat_id,"Enable")
	locks(msg,chat_id,'➰ قفل تگ','Lock:Tag:','locktag:','Settings:')
end
if cerner == 'locktag:disable:'..chat_id then
	redis:del('Lock:Tag:'..chat_id)
	locks(msg,chat_id,'➰ قفل تگ','Lock:Tag:','locktag:','Settings:')
end
-------------------------------------
if cerner == 'lockhashtag:'..chat_id then
	locks(msg,chat_id,'➰ قفل هشتگ','Lock:HashTag:','lockhashtag:','Settings:')
end
if cerner == 'lockhashtag:kick:'..chat_id then
	redis:set('Lock:HashTag:'..chat_id,"Kick")
	locks(msg,chat_id,'➰ قفل هشتگ','Lock:HashTag:','lockhashtag:','Settings:')
end
if cerner == 'lockhashtag:warn:'..chat_id then
	redis:set('Lock:HashTag:'..chat_id,"Warn")
	locks(msg,chat_id,'➰ قفل هشتگ','Lock:HashTag:','lockhashtag:','Settings:')
end
if cerner == 'lockhashtag:mute:'..chat_id then
	redis:set('Lock:HashTag:'..chat_id,"Mute")
	locks(msg,chat_id,'➰ قفل هشتگ','Lock:HashTag:','lockhashtag:','Settings:')
end
if cerner == 'lockhashtag:enable:'..chat_id then
	redis:set('Lock:HashTag:'..chat_id,"Enable")
	locks(msg,chat_id,'➰ قفل هشتگ','Lock:HashTag:','lockhashtag:','Settings:')
end
if cerner == 'lockhashtag:disable:'..chat_id then
	redis:del('Lock:HashTag:'..chat_id)
	locks(msg,chat_id,'➰ قفل هشتگ','Lock:HashTag:','lockhashtag:','Settings:')
end
-------------------------------------
if cerner == 'lockinline:'..chat_id then 
	locks(msg,chat_id,'➰ قفل هشتگ','Lock:Inline:','lockinline:','Settings:')
end
if cerner == 'lockinline:kick:'..chat_id then
	redis:set('Lock:Inline:'..chat_id,"Kick")
	locks(msg,chat_id,'➰ قفل دکمه شیشه ای','Lock:Inline:','lockinline:','Settings:')
end
if cerner == 'lockinline:warn:'..chat_id then
	redis:set('Lock:Inline:'..chat_id,"Warn")
	locks(msg,chat_id,'➰ قفل دکمه شیشه ای','Lock:Inline:','lockinline:','Settings:')
end
if cerner == 'lockinline:mute:'..chat_id then
	redis:set('Lock:Inline:'..chat_id,"Mute")
	locks(msg,chat_id,'➰ قفل دکمه شیشه ای','Lock:Inline:','lockinline:','Settings:')
end
if cerner == 'lockinline:enable:'..chat_id then
	redis:set('Lock:Inline:'..chat_id,"Enable")
	locks(msg,chat_id,'➰ قفل دکمه شیشه ای','Lock:Inline:','lockinline:','Settings:')
end
if cerner == 'lockinline:disable:'..chat_id then
	redis:del('Lock:Inline:'..chat_id)
	locks(msg,chat_id,'➰ قفل دکمه شیشه ای','Lock:Inline:','lockinline:','Settings:')
end
-------------------------------------
if cerner == 'lockvideo_note:'..chat_id then 
	locks(msg,chat_id,'➰ قفل فیلم سلفی','Lock:Video_note:','lockvideo_note:','Settings:')
end
if cerner == 'lockvideo_note:kick:'..chat_id then
	redis:set('Lock:Video_note:'..chat_id,"Kick")
	locks(msg,chat_id,'➰ قفل فیلم سلفی','Lock:Video_note:','lockvideo_note:','Settings:')
end
if cerner == 'lockvideo_note:warn:'..chat_id then
	redis:set('Lock:Video_note:'..chat_id,"Warn")
	locks(msg,chat_id,'➰ قفل فیلم سلفی','Lock:Video_note:','lockvideo_note:','Settings:')
end
if cerner == 'lockvideo_note:mute:'..chat_id then
	redis:set('Lock:Video_note:'..chat_id,"Mute")
	locks(msg,chat_id,'➰ قفل فیلم سلفی','Lock:Video_note:','lockvideo_note:','Settings:')
end
if cerner == 'lockvideo_note:enable:'..chat_id then
	redis:set('Lock:Video_note:'..chat_id,"Enable")
	locks(msg,chat_id,'➰ قفل فیلم سلفی','Lock:Video_note:','lockvideo_note:','Settings:')
end
if cerner == 'lockvideo_note:disable:'..chat_id then
	redis:del('Lock:Video_note:'..chat_id)
	locks(msg,chat_id,'➰ قفل فیلم سلفی','Lock:Video_note:','lockvideo_note:','Settings:')
end
-------------------------------------
if cerner == 'lockbot:'..chat_id then
if redis:get('Lock:Bot:'..chat_id) then
redis:del('Lock:Bot:'..chat_id)
Alert(Company.id,"➰ قفل ورود ربات غیرفعال شد")
else
redis:set('Lock:Bot:'..chat_id,true)
Alert(Company.id,"➰ قفل ورود ربات فعال شد")
end
setting2(msg,chat_id)
end
-------------------------------------
----------------------------------------
if cerner == 'groupinfo:'..chat_id then
local expire = redis:ttl("ExpireData:"..chat_id)
if expire == -1 then
EXPIRE = "نامحدود"
else
local d = math.floor(expire / day ) + 1
EXPIRE = d.."  روز"
end
-----
local text = '➰ اطلاعات گروه'
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '➰ تاریخ انقضا : '..EXPIRE..'', callback_data = 'cerner'..chat_id}
},{
{text = '➰ لیست مدیران', callback_data = 'modlist:'..chat_id},{text = '➰ لیست مالکان', callback_data = 'ownerlist:'..chat_id}
},{
{text = '➰ لیست فیلتر', callback_data = 'filterlist:'..chat_id},{text = '➰ لیست سکوت', callback_data = 'silentlist:'..chat_id}
},{
{text = '➰ لیست مسدود', callback_data = 'Banlist:'..chat_id},{text = '➰ لیست ویژه', callback_data = 'Viplist:'..chat_id}
},{
{text = '➰ لینک گروه', callback_data = 'GroupLink:'..chat_id},{text = '➰ قوانین', callback_data = 'GroupRules:'..chat_id}
},{
{text = '➰ موقعیت خوشآمد گویی', callback_data = 'update'..chat_id}
},{
{text = '🔙 بازگشت', callback_data = 'Menu:'..chat_id}
}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'ownerlist:'..chat_id then
local OwnerList = redis:smembers('OwnerList:'..chat_id)
local text = 'لیست مالکان گروه :\n'
for k,v in pairs(OwnerList) do
text = text..k.." - *"..v.."*\n" 
end
text = text.."\n➰ برای مشاهده میتوانید از دستور زیر استفاده کنید\n"..UserBotHelper.." "..Sudoid..""
if #OwnerList == 0 then
text = '➰ لیست مورد نظر خالی میباشد !'
end
local keyboard = {}
keyboard.inline_keyboard = {{{text = '🔙 بازگشت ', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'Viplist:'..chat_id then
local VipList = redis:smembers('Vip:'..chat_id)
local text = 'لیست ویژه گروه :\n'
for k,v in pairs(VipList) do
text = text..k.." - `"..v.."`\n" 
end
text = text.."\n➰ برای مشاهده میتوانید از دستور زیر استفاده کنید\n"..UserBotHelper.." "..Sudoid..""
if #VipList == 0 then
text = '➰ لیست مورد نظر خالی میباشد !'
local keyboard = {}
keyboard.inline_keyboard = {{{text = '🔙 بازگشت ', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
else
local keyboard = {}
keyboard.inline_keyboard = {{{text = '➰ پاک کردن ', callback_data = 'cleanViplist:'..chat_id}},{{text = '🔙 بازگشت ', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
end
if cerner == 'cleanViplist:'..chat_id then
local text = [[`لیست ویژه` *پاکسازی شد*]]
redis:del('Vip:'..chat_id)
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '🔙 بازگشت', callback_data = 'groupinfo:'..chat_id}
}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'modlist:'..chat_id then
local ModList = redis:smembers('ModList:'..chat_id)
local text = 'لیست مدیران گروه :\n'
for k,v in pairs(ModList) do
text = text..k.." - *"..v.."*\n" 
end
text = text.."\n➰ برای مشاهده میتوانید از دستور زیر استفاده کنید\n"..UserBotHelper.." "..Sudoid..""
if #ModList == 0 then
text = '➰ لیست مورد نظر خالی میباشد !'
local keyboard = {}
keyboard.inline_keyboard = {{{text = '🔙 بازگشت ', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
else
local keyboard = {}
keyboard.inline_keyboard = {{{text = '➰ پاک کردن ', callback_data = 'cleanmodlist:'..chat_id}},{{text = '🔙 بازگشت ', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
end
 if cerner == 'Banlist:'..chat_id then
local BanUser = redis:smembers('BanUser:'..chat_id)
local text = 'لیست مسدودیا گروه :\n'
for k,v in pairs(BanUser) do
text = text..k.." - *"..v.."*\n" 
end
text = text.."\n➰ برای مشاهده میتوانید از دستور زیر استفاده کنید\n"..UserBotHelper.." "..Sudoid..""
if #BanUser == 0 then
text = '➰ لیست مورد نظر خالی میباشد !'
local keyboard = {}
keyboard.inline_keyboard = {{{text = '🔙 بازگشت ', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
else
local keyboard = {}
keyboard.inline_keyboard = {{{text = '➰ پاک کردن ', callback_data = 'cleanbanlist:'..chat_id}},{{text = '🔙 بازگشت ', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
end
if cerner == 'silentlist:'..chat_id then
 local Silentlist = redis:smembers('MuteUser:'..chat_id)
 local text = 'لیست کاربران سکوت :\n'
 for k,v in pairs(Silentlist) do
 text = text..k.." - *"..v.."*\n" 
 end
text = text.."\n➰ برای مشاهده میتوانید از دستور زیر استفاده کنید\n"..UserBotHelper.." "..Sudoid..""
  if #Silentlist == 0 then
text = '➰ *➰ لیست مورد نظر خالی میباشد !*'
local keyboard = {}
keyboard.inline_keyboard = {{{text = '🔙 بازگشت ', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
else
local keyboard = {}
keyboard.inline_keyboard = {{
{text = '➰ پاک کردن', callback_data = 'cleansilentlist:'..chat_id}},{
{text = '🔙 بازگشت', callback_data = 'groupinfo:'..chat_id}
}}
EditInline(msg.inline_id,text,keyboard)
 end
 end
if cerner == 'cleanbanlist:'..chat_id then
local text = [[`لیست مسدود` *پاکسازی شد*]]
redis:del('BanUser:'..chat_id)
local keyboard = {}
keyboard.inline_keyboard = {{{text = '🔙 بازگشت', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'filterlist:'..chat_id then
 local Filters = redis:smembers('Filters:'..chat_id)
 local text = 'لیست کلمات فیلتر گروه :\n'
 for k,v in pairs(Filters) do
 text = text..k.." - *"..v.."*\n" 
 end
  if #Filters == 0 then
text = '➰ *➰ لیست مورد نظر خالی میباشد !*'
local keyboard = {}
keyboard.inline_keyboard = {{{text = '🔙 بازگشت ', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
else
local keyboard = {}
keyboard.inline_keyboard = {{
{text = '➰ پاک کردن', callback_data = 'cleanFilters:'..chat_id}},{
{text = '🔙 بازگشت', callback_data = 'groupinfo:'..chat_id}
}}
EditInline(msg.inline_id,text,keyboard)
 end
 end
if cerner == 'cleanFilters:'..chat_id then
local text = [[`لیست فیلتر` *پاکسازی شد*]]
redis:del('Filters:'..chat_id)
local keyboard = {}
keyboard.inline_keyboard = {{{text = '🔙 بازگشت', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'GroupLink:'..chat_id then
local link = redis:get('Link:'..chat_id)
if link then 
local keyboard = {}
keyboard.inline_keyboard = {{
{text = '➰ حذف لینک ', callback_data = 'Dellink:'..chat_id}},{
{text = '🔙 بازگشت', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,link,keyboard)
else
local keyboard = {}
keyboard.inline_keyboard = {{
{text = '🔙 بازگشت', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,'➰ *لینک گروه ثبت نشده است*',keyboard)
end
end
if cerner == 'Dellink:'..chat_id then
redis:del('Link:'..chat_id)
local keyboard = {}
keyboard.inline_keyboard = {{
{text = '🔙 بازگشت', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,'➰ *لینک گروه حذف شد*',keyboard)
end
if cerner == 'GroupRules:'..chat_id then
local rules = redis:get('Rules:'..chat_id)
if rules then 
local keyboard = {}
keyboard.inline_keyboard = {{
{text = '➰ حذف قوانین ', callback_data = 'Delrules:'..chat_id}},{
{text = '🔙 بازگشت', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,rules,keyboard)
else
local keyboard = {}
keyboard.inline_keyboard = {{
{text = '🔙 بازگشت', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,'➰ *قوانین گروه ثبت نشده است*',keyboard)
end
end
if cerner == 'Delrules:'..chat_id then
redis:del('Rules:'..chat_id)
local keyboard = {}
keyboard.inline_keyboard = {{
{text = '🔙 بازگشت', callback_data = 'groupinfo:'..chat_id}}}
EditInline(msg.inline_id,'➰ *قوانین گروه حذف شد*',keyboard)
end
---------------------------------------------------------------
if cerner == 'automuteall:'..chat_id then
if redis:get('automuteall'..chat_id) then
redis:del('automuteall'..chat_id)
Alert(Company.id, "➰ قفل خودکار غیرفعال شد")
else
redis:set('automuteall'..chat_id,true)
Alert(Company.id, "➰ قفل خودکار فعال شد")
end
setting3(msg,chat_id)
end
if cerner == 'lockflood:'..chat_id then
if redis:get('Lock:Flood:'..chat_id) then
redis:del('Lock:Flood:'..chat_id)
 Alert(Company.id, "➰ قفل فلود غیرفعال شد")
else
redis:set('Lock:Flood:'..chat_id,true)
Alert(Company.id, "➰ قفل فلود فعال شد")
end
setting3(msg,chat_id)
end
if cerner == 'lockspam:'..chat_id then
if redis:get('Spam:Lock:'..chat_id) then
redis:del('Spam:Lock:'..chat_id)
 Alert(Company.id, "➰ قفل اسپم غیرفعال شد ")
else
redis:set('Spam:Lock:'..chat_id,true)
Alert(Company.id, "➰ قفل اسپم فعال شد")
end
setting3(msg,chat_id)
end
if cerner == 'lockcommand:'..chat_id then
if redis:get('Lock:Cmd'..chat_id) then
redis:del('Lock:Cmd'..chat_id)
 Alert(Company.id, "➰ قفل دستورات برای کاربر عادی غیر فعال شد")
else
redis:set('Lock:Cmd'..chat_id,true)
Alert(Company.id, "➰ قفل دستورات برای کاربر عادی فعال شد")
end
setting3(msg,chat_id)
end
if cerner == 'muteall:'..chat_id then
if redis:get('MuteAll:'..chat_id) then
redis:del('MuteAll:'..chat_id)
 Alert(Company.id, "➰ قفل گروه غیرفعال شد")
else
redis:set('MuteAll:'..chat_id,true)
Alert(Company.id, "➰ قفل گروه فعال شد")
end
setting3(msg,chat_id)
end
if cerner == 'MSGMAXup:'..chat_id then
if tonumber(MSG_MAX) == 15 then
Alert(Company.id,'حداکثر مقدار 15' ,true)
else
MSG_MAX = (redis:get('Flood:Max:'..chat_id) or 6)
MSG_MAX = tonumber(MSG_MAX) + 1
Alert(Company.id,MSG_MAX)
redis:set('Flood:Max:'..chat_id,MSG_MAX)
end
setting3(msg,chat_id)
end
if cerner == 'MSGMAXdown:'..chat_id then
if tonumber(MSG_MAX) == 3 then
Alert(Company.id,'حداقل مقدار 3' ,true)
else
MSG_MAX = (redis:get('Flood:Max:'..chat_id) or 6)
MSG_MAX = tonumber(MSG_MAX) - 1
Alert(Company.id,MSG_MAX)
redis:set('Flood:Max:'..chat_id,MSG_MAX)
end
setting3(msg,chat_id)
end
if cerner == 'TIMEMAXup:'..chat_id then
if tonumber(TIME_CHECK) == 9 then
Alert(Company.id,'حداکثر مقدار 9')
else
TIME_CHECK = (redis:get('Flood:Time:'..chat_id) or 2)
TIME_CHECK = tonumber(TIME_CHECK) + 1
Alert(Company.id,TIME_CHECK)
redis:set('Flood:Time:'..chat_id,TIME_CHECK)
end
setting3(msg,chat_id)
end
if cerner == 'TIMEMAXdown:'..chat_id then
if tonumber(TIME_CHECK) == 2 then
Alert(Company.id,'حداقل مقدار 2' ,true)
else
TIME_CHECK = (redis:get('Flood:Time:'..chat_id) or 2)
TIME_CHECK = tonumber(TIME_CHECK) - 1
Alert(Company.id,TIME_CHECK)
redis:set('Flood:Time:'..chat_id,TIME_CHECK)
end
setting3(msg,chat_id)
end
if cerner == 'CHMAXup:'..chat_id then
if tonumber(CH_MAX) == 4096 then
Alert(Company.id,'حداکثر مقدار 4096' ,true)
else
CH_MAX = (redis:get('NUM_CH_MAX:'..chat_id) or 200)
CH_MAX= tonumber(CH_MAX) + 50
Alert(Company.id,CH_MAX)
redis:set('NUM_CH_MAX:'..chat_id,CH_MAX)
end
setting3(msg,chat_id)
end
if cerner == 'CHMAXdown:'..chat_id then
if tonumber(CH_MAX) == 50 then
Alert(Company.id,'حداقل مقدار 50' ,true)
else
CH_MAX = (redis:get('NUM_CH_MAX:'..chat_id) or 200)
CH_MAX= tonumber(CH_MAX) - 50
Alert(Company.id,CH_MAX)
redis:set('NUM_CH_MAX:'..chat_id,CH_MAX)
end
setting3(msg,chat_id)
end
if cerner == 'floodstatus:'..chat_id then
local hash = redis:get('Flood:Status:'..chat_id)
if hash then
if redis:get('Flood:Status:'..chat_id) == 'kickuser' then
redis:set('Flood:Status:'..chat_id,'muteuser')
Status = 'سکوت کاربر'
Alert(Company.id,'وضعیت فلود بر روی '..Status..' قرار گرفت')
elseif redis:get('Flood:Status:'..chat_id) == 'muteuser' then
redis:set('Flood:Status:'..chat_id,'deletemsg')
Status = 'حذف پیام'
Alert(Company.id,'وضعیت فلود بر روی '..Status..' قرار گرفت')
elseif redis:get('Flood:Status:'..chat_id) == 'deletemsg' then
redis:del('Flood:Status:'..chat_id)
Status = 'تنظیم نشده'
Alert(Company.id,'وضعیت فلود بر روی '..Status..' قرار گرفت')
end
else
redis:set('Flood:Status:'..chat_id,'kickuser')
Status = 'اخراج کاربر'
Alert(Company.id,'وضعیت فلود بر روی '..Status..' قرار گرفت')
end
setting3(msg,chat_id)
end
------------------------------------------------------
end --Alert not mod
end --Alert CerNer
-----------------End Mod---------------
----------------Start Owner ----------------------
if not is_Owner(chat_id,Company.from.id) then
Alert(Company.id,'➰ کاربر '..msg.user_first..' شما دسترسی کافی ندارید')
else
if cerner == 'cleanmodlist:'..chat_id then
local text = [[`لیست مدیران`  *پاکسازی شد*]]
redis:del('ModList:'..chat_id)
local keyboard = {}
keyboard.inline_keyboard = {
{
{text = '🔙 بازگشت', callback_data = 'groupinfo:'..chat_id}
}}
EditInline(msg.inline_id,text,keyboard)
end
if cerner == 'lockpin'..chat_id then
if redis:get('Lock:Pin:'..chat_id) then
redis:del('Lock:Pin:'..chat_id)
Alert(Company.id, "➰ قفل سنجاق غیرفعال شد !")
else
redis:set('Lock:Pin:'..chat_id,true)
Alert(Company.id, "➰ قفل  سنجاق فعال  شد ً!")
end
setting1(msg,chat_id)
end
-----------------------
end -- Alert not Owner
-----------------
if msg.message and msg.message.date < tonumber(MsgTime) then
print('OLD MESSAGE')
 return false
end
end
end
end
end
end
return Running()
