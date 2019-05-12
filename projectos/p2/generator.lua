-- This script generates tests for the 

local charset = {
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
    '-', '_', '.',
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
}

local cmds = {'a', 'a', 'a', 'a', 'a', 'a', 'r', 'r', 'r', 'a', 'r', 'a', 'r', 'a', 'a', 'a', 'l', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'r', 'r', 'e', 'e', 'r', 'r', 'e', 'e', 'c', 'c', 'c', 'c', 'a', 'a', 'a', 'a', 'a', 'a', 'r', 'r', 'r', 'a', 'r', 'a', 'r', 'a', 'a', 'a', 'c', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'r', 'r', 'e', 'e', 'r', 'r', 'e', 'e', 'c', 'c', 'c', 'c'}

local contact_names = {}
local mail_domains = {}

-- We use this when we don't want to have equal chances :)
function unfair_random(a)
    local aux = math.random(1, a*100)/(a*100)
    aux = aux^10 -- since the values are between 0 and 1, this will make larger values more rare

    return math.ceil(aux * a)
end

function makeName()
    local x = ""
    local len = unfair_random(1023)

    for i = 1, len do
        x = x..charset[math.random(1, #charset)]
    end

    table.insert(contact_names, x)
    return x
end

function makeMail()
    local domain = ""
    local dlen = 0
    local fromlist = false

    if (math.random(1, 100) <= 70 and table.maxn(mail_domains) ~= 0) then
        domain = mail_domains[math.random(1, #mail_domains)]
        dlen = string.len(domain)
        fromlist = true
    else
        dlen = unfair_random(509)
        fromlist = false
        for i = 1, dlen do
            domain = domain..charset[math.random(1, #charset)]
        end
    end
        
    local name = ""
    local nlen = unfair_random(510 - dlen)

    for i = 1, nlen do
        name = name..charset[math.random(1, #charset)]
    end

    if fromlist then
        table.insert(mail_domains, domain)
    end
    return (name..'@'..domain)
end

function makePhone()
    local x = ""
    local len = unfair_random(63)

    for i = 1, len do
        x = x..charset[math.random(1, #charset)]
    end

    return x
end

local gen_cmds = {
    a = function()
        local name, email, phone
        if math.random(1, 100) <= 20 and table.maxn(contact_names) ~= 0 then
            name = contact_names[math.random(1, #contact_names)]
        else
            name = makeName()
        end
        email = makeMail()
        phone = makePhone()

        io.write("a "..name.." "..email.." "..phone.."\n")
    end,

    l = function()
        io.write("l\n")
    end,

    p = function()
        local name
        if math.random(1, 100) <= 80 and table.maxn(contact_names) ~= 0 then
            name = contact_names[math.random(1, #contact_names)]
        else
            name = makeName()
        end

        io.write("p "..name.."\n")
    end,

    r = function()
        local name
        if math.random(1, 100) <= 80 and table.maxn(contact_names) ~= 0 then
            name = contact_names[math.random(1, #contact_names)]
        else
            name = makeName()
        end

        io.write("r "..name.."\n")
    end,

    e = function()
        local name
        if math.random(1, 100) <= 80 and table.maxn(contact_names) ~= 0 then
            name = contact_names[math.random(1, #contact_names)]
        else
            name = makeName()
        end

        io.write("r "..name.." "..makeMail().."\n")
    end,

    c = function()
        local domain = ""
        if math.random(1, 100) <= 50 and table.maxn(mail_domains) ~= 0 then
            domain = mail_domains[math.random(1, #mail_domains)]
        else
            for i = 1, unfair_random(509) do
                domain = domain..charset[math.random(1, #charset)]
            end
        end

        io.write("c "..domain.."\n")
    end
}

-- Main script
math.randomseed(os.time())
local n = 0

-- Make sure we have a positive number...
while n <= 0 do
    print("Number of commands?")
    n = io.read("*n")
end
local fn = "tests-community/community_test_"..tostring(n).."_"..math.random(1, 1024)..".in"
print("Flushing to "..fn.."...")

os.execute("mkdir tests-community")
local f = io.open(fn, "a")
io.output(f)

local lastTime = os.time()

for i = 1, n do
    gen_cmds[cmds[math.random(1, #cmds)]]()
    if not (os.time() - lastTime == 0) then
        lastTime = os.time()
        print(i.."/"..n.." commands written ("..(math.floor((i/n) * 1000)/10).."%)")
    end
end

print(n.."/"..n.." commands written (100.0%)")
io.write("x")
io.close(f)
