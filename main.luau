if not game:IsLoaded() then game.Loaded:Wait(); end;

local cloneref = cloneref or function(i: Instance) return i; end;
local clonefunction = clonefunction or function(f: (...any) -> (...any)) return f; end;
local newcclosure = newcclosure or clonefunction;
local executor = (identifyexecutor and select(2, pcall(identifyexecutor))) and identifyexecutor() or "Your executor";

if not (hookfunction and require) then
    return error(executor .. " is missing " .. (not hookfunction and "hookfunction " or "") .. (not require and "require" or ""));
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

local main = Instance.new("ScreenGui", hui);
main.Name = "";

local mode = Instance.new("TextButton", main);
mode.Name = "";
mode.Text = "Click Me!";
mode.AnchorPoint = Vector2.new(1, 0)
mode.Position = UDim2.new(1, 0, 0, 0);
mode.Size = UDim2.new(0.1, 0, 0.1, 0);

local _mode = false;

local isSameTeam = function(player)
    if not player or not player:IsA("Player") then return false; end;

    local myTeam = plr.Team.Name;
    local theirTeam = player.Team.Name;

    if theirTeam == "Civilians" then
        return true;
    end;

    if myTeam == "Cowboys" and theirTeam == "Cowboys" then
        return true;
    end;

    if myTeam == "Outlaws" and theirTeam == "Outlaws" then
        return false;
    end;

    return false;
end;

local getTarget = function(): BasePart
    local cPart, cDistance = nil, 250;

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
        if args[1] and args[2] and args[5] then
            local c = getTarget();
            if c then
                print(Players:GetPlayerFromCharacter(c.Parent));
                args[1] = c;
                args[2] = c.Position;
                args[5].HitPosition = c.Position;
                args[5].HitPart = c;
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
