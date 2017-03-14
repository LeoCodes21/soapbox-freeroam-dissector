--
-- Created by IntelliJ IDEA.
-- User: heyitsleo
-- Date: 3/13/17
-- Time: 8:54 PM
-- To change this template use File | Settings | File Templates.
--
function setPosFields(buf, pkt, subtree)
--    setCountField(buf, pkt, subtree)
    local cli_cli_type = detectDirection(pkt)
    if (cli_cli_type == 'C->S') then
        subtree:add(f_fr_pname, buf(55, 24)) -- padding
        subtree:add(f_fr_pid, buf(95, 1)) -- padding
        subtree:add(f_fr_channel, buf(20, 16)) -- padding
    end
    pkt.cols.protocol = 'SB-POS'
    pkt.cols.info = 'POS Protocol [' .. cli_cli_type .. ']'
end

