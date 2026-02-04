if not game:IsLoaded() then game.Loaded:Wait(); end;

local cloneref = cloneref or function(i: Instance) return i; end;
local clonefunction = clonefunction or function(f: (...any) -> (...any)) return f; end;
local newcclosure = newcclosure or clonefunction;
local executor = (identifyexecutor and select(2, pcall(identifyexecutor))) and identifyexecutor() or "Your executor";

if not (hookfunction and filtergc or (getgc and debug.getconstants)) then
    return error(executor .. " is missing " .. (not hookfunction and "hookfunction " or "") .. (not (filtergc and (getgc and debug.getconstants)) and "filtergc getgc debug.getconstants" or ""));
end;

local Players: Players = cloneref(game:GetService("Players"));
local RS: ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"));
local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"));
local hui: BasePlayerGui | Folder = (gethui and cloneref(gethui())) or CoreGui:FindFirstChild("RobloxGui") or CoreGui;

local plr = Players.LocalPlayer;
local cam = workspace.CurrentCamera;

local mouse = plr:GetMouse();

local Hit = RS.GunScripts.CreateShot.Hit;
local Animals: Folder = workspace.Animals;

local teams = loadstring(game:HttpGet("https://raw.githubusercontent.com/sneekygoober/Westbound-Silent-Aim-Script/refs/heads/main/Teams.luau"))();

local main = Instance.new("ScreenGui", hui);
main.Name = "";

local mode = Instance.new("TextButton", main);
mode.Name = "";
mode.Text = "Click Me!";
mode.AnchorPoint = Vector2.new(1, 0)
mode.Position = UDim2.new(1, 0, 0, 0);
mode.Size = UDim2.new(0.1, 0, 0.1, 0);

local _mode = false;

local isSameTeam = function(player: Player)
    if not player:IsA("Player") then return false; end;
    if teams[player.Team.Name] == 0 then return true; end;
    return teams[player.Team.Name] == teams[plr.Team.Name];
end;

local isVisible = function(part: BasePart, origin: Vector3): (boolean, Instance?)
    local char = plr.Character;
    if not char then return false, nil; end;

    local rp = RaycastParams.new();
    rp.FilterType = Enum.RaycastFilterType.Exclude;
    rp.FilterDescendantsInstances = {char};
    rp.IgnoreWater = true;

    local dir = part.Position - origin;
    local result: RaycastResult = workspace:Raycast(origin, dir, rp);
    if not result then return true, nil; end;

    if result.Instance:IsDescendantOf(part.Parent) then
        return true, result.Instance;
    end;

    return false, result.Instance;
end;

local getTarget = function(origin: Vector3): BasePart
    local cPart, cDistance = nil, math.huge;

    local group = _mode and Players or Animals;

    for _, targ: Player | Model in next, group:GetChildren() do
        if targ == plr or isSameTeam(targ) then continue; end;

        local char;
        if _mode then char = targ.Character; else char = targ; end;
        if not char or char:FindFirstChildOfClass("ForceField") then continue; end;

        local tPart: BasePart = char:FindFirstChild("Head") or char.PrimaryPart or char:FindFirstChild("HumanoidRootPart");
        if not tPart then continue; end;

        local pos, onScreen = cam:WorldToViewportPoint(tPart.Position);
        if not onScreen then continue; end;

        local v, nTPart = isVisible(tPart, origin);
        if not v then
            v, nTPart = isVisible(char.PrimaryPart or char:FindFirstChild("HumanoidRootPart"), origin);
            if not v then continue; end;
        end;

        if nTPart then tPart = nTPart; end;

        local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude;
        if distance < cDistance then
            cPart = tPart;
            cDistance = distance;
        end;
    end;

    return cPart;
end;

local init = function()
    local f = loadstring(game:HttpGet("https://raw.githubusercontent.com/sneekygoober/sneeky-s-filtergc/refs/heads/main/main.luau"))()(Hit, false, "Window", "Frying Pan", "Head", "Eyes", "Rein", "Hit", "EndPoint", "Handle");
    if not f then return warn("Script failed to find function"); end;

    local old; old = clonefunction(hookfunction(f, newcclosure(function(...)
        local args = {...};
        if args[1] and args[2] and args[5] and args[5]["cframe"] and args[5]["cframe"]["p"] then
            local c = getTarget(args[5].cframe.p);
            if c then
                local npos = c.Position;
                args[1] = c;
                args[2] = npos;
                args[5]["HitPosition"] = npos;
                args[5]["HitPart"] = c;
                return old(unpack(args));
            end;
        end;

        return old(...);
    end)));
end;

mode.MouseButton1Click:Connect(function()
    _mode = not _mode;
    if mode.Text == "Click Me!" then init(); end;
    mode.Text = _mode and "Target: Players" or "Target: Animals";
end);
