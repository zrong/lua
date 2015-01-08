--- A LogHandler save log to rsyslog socket.
-- @author zrong
-- Creation: 2014-11-14

local SyslogHandler = class('SyslogHandler', import('.LogHandler'))
import('..utils.bit')
local Logger = import('.Logger')

--[[ from python 3.4.2 logging.SysLogHandler
# from <linux/sys/syslog.h>:
# ======================================================================
# priorities/facilities are encoded into a single 32-bit quantity, where
# the bottom 3 bits are the priority (0-7) and the top 28 bits are the
# facility (0-big number). Both the priorities and the facilities map
# roughly one-to-one to strings in the syslogd(8) source code.  This
# mapping is included in this file.
#
# priorities (these are ordered)
]]

local SYSLOG_UDP_PORT             = 514
local SYSLOG_TCP_PORT             = 514

local LOG_EMERG     = 0       --  system is unusable
local LOG_ALERT     = 1       --  action must be taken immediately
local LOG_CRIT      = 2       --  critical conditions
local LOG_ERR       = 3       --  error conditions
local LOG_WARNING   = 4       --  warning conditions
local LOG_NOTICE    = 5       --  normal but significant condition
local LOG_INFO      = 6       --  informational
local LOG_DEBUG     = 7       --  debug-level messages

--  facility codes
local LOG_KERN      = 0       --  kernel messages
local LOG_USER      = 1       --  random user-level messages
local LOG_MAIL      = 2       --  mail system
local LOG_DAEMON    = 3       --  system daemons
local LOG_AUTH      = 4       --  security/authorization messages
local LOG_SYSLOG    = 5       --  messages generated internally by syslogd
local LOG_LPR       = 6       --  line printer subsystem
local LOG_NEWS      = 7       --  network news subsystem
local LOG_UUCP      = 8       --  UUCP subsystem
local LOG_CRON      = 9       --  clock daemon
local LOG_AUTHPRIV  = 10      --  security/authorization messages (private)
local LOG_FTP       = 11      --  FTP daemon

--  other codes through 15 reserved for system use
local LOG_LOCAL0    = 16      --  reserved for local use
local LOG_LOCAL1    = 17      --  reserved for local use
local LOG_LOCAL2    = 18      --  reserved for local use
local LOG_LOCAL3    = 19      --  reserved for local use
local LOG_LOCAL4    = 20      --  reserved for local use
local LOG_LOCAL5    = 21      --  reserved for local use
local LOG_LOCAL6    = 22      --  reserved for local use
local LOG_LOCAL7    = 23      --  reserved for local use

local priority_names = {
    ["alert"]=    LOG_ALERT,
    ["crit"]=     LOG_CRIT,
    ["critical"]= LOG_CRIT,
    ["debug"]=    LOG_DEBUG,
    ["emerg"]=    LOG_EMERG,
    ["err"]=      LOG_ERR,
    ["error"]=    LOG_ERR,        --  DEPRECATED
    ["info"]=     LOG_INFO,
    ["notice"]=   LOG_NOTICE,
    ["panic"]=    LOG_EMERG,      --  DEPRECATED
    ["warn"]=     LOG_WARNING,    --  DEPRECATED
    ["warning"]=  LOG_WARNING,
}

local facility_names = {
    ["auth"]=     LOG_AUTH,
    ["authpriv"]= LOG_AUTHPRIV,
    ["cron"]=     LOG_CRON,
    ["daemon"]=   LOG_DAEMON,
    ["ftp"]=      LOG_FTP,
    ["kern"]=     LOG_KERN,
    ["lpr"]=      LOG_LPR,
    ["mail"]=     LOG_MAIL,
    ["news"]=     LOG_NEWS,
    ["security"]= LOG_AUTH,       --  DEPRECATED
    ["syslog"]=   LOG_SYSLOG,
    ["user"]=     LOG_USER,
    ["uucp"]=     LOG_UUCP,
    ["local0"]=   LOG_LOCAL0,
    ["local1"]=   LOG_LOCAL1,
    ["local2"]=   LOG_LOCAL2,
    ["local3"]=   LOG_LOCAL3,
    ["local4"]=   LOG_LOCAL4,
    ["local5"]=   LOG_LOCAL5,
    ["local6"]=   LOG_LOCAL6,
    ["local7"]=   LOG_LOCAL7,
}

--[[
#The map below appears to be trivially lowercasing the key. However,
#there's more to it than meets the eye - in some locales, lowercasing
#gives unexpected results. See SF #1524081: in the Turkish locale,
#"INFO".lower() != "info"
]]

local priority_map = {
    [Logger.CRITICAL] = 'critical',
    [Logger.ERROR] = 'error',
    [Logger.WARNING] = 'warning',
    [Logger.INFO] = 'info',
    [Logger.DEBUG] = 'debug',
}

local logfmt = {
    '<%d>1', 
    '%Y-%m-%dT%H:%M:%S.000000+08:00', -- TIMESTAMP 2015-01-06T20:07:10.022787+08:00
    'HOSTNAME',
    'team1201',
    'APP-NAME',
    '9999', -- PROCID
    '-',    -- MSGID
    '-',    -- SEP
}

-- @host socket host
-- @port socket port
-- @autoflush Default value is false。
function SyslogHandler:ctor(adapter, facility, appname, autoflush)
    SyslogHandler.super.ctor(self)
    self._ada = adapter
    self.facility = facility
    self._appname = appname or 'NO-APP-NAME'
    self._autoflush = autoflush
end

--[[ from python 3.4.2 logging.SysLogHandler
Encode the facility and priority. You can pass in strings or
integers - if strings are passed, the facility_names and
priority_names mapping dictionaries are used to convert them to
integers.
]]
function SyslogHandler:encodePriority(facility, priority)
    if type(facility) == 'string' then
        facility = facility_names[facility]
    end
    if type(priority) == 'string' then
        priority = priority_names[priority]
    end
    return bit.bor(bit.lshift(facility, 3), priority)
end

--[[ from python 3.4.2 logging.SysLogHandler
Map a logging level name to a key in the priority_names map.
This is useful in two scenarios: when custom levels are being
used, and in the case where you can't do a straightforward
mapping by lowercasing the logging level name because of locale-
specific issues (see SF #1524081).
]]
function SyslogHandler:mapPriority(level)
    return priority_map[level] or 'warning'
end

function SyslogHandler:emit(level, fmt, args)
    str = self:getString(level, fmt, args)
    local succ, err = self._ada:log(str)
    if err then
        print("failed to log message: ", err)
        return
    end
    if self._autoflush then
        self:flush()
    end
end

function SyslogHandler:getString(level, fmt, args)
    local strlist = clone(logfmt)
    strlist[1] = string.format(strlist[1], 
        self:encodePriority(self.facility, self:mapPriority(level)))
    strlist[2] = os.date(strlist[2])
    strlist[4] = self._appname
    if #args > 0 and 
        type(fmt) == 'string' and
        string.find(fmt, "%%") then
        strlist[#strlist+1] = string.format(fmt, unpack(args))
    else
        strlist[#strlist+1] = fmt
        for i=1, #args do
            strlist[#strlist+1] = tostring(args[i])
        end
    end
    strlist[#strlist+1] = '\n'
    return table.concat(strlist, ' ')
end

function SyslogHandler:flush()
    self._ada:flush()
end

return SyslogHandler
