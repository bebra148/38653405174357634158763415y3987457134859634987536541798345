-- Список разрешённых SteamID (добавь свои)
local allowedSteamIDs = {
    ["STEAM_0:0:923364789"] = true, --bumkin
    ["STEAM_0:1:921132691"] = true, --bumkin
    ["STEAM_0:1:600204671"] = true, --bumkin
    ["STEAM_0:0:893334411"] = true, --dezz
    ["STEAM_1:1:813771985"] = true, --dubley
    ["STEAM_0:1:508504180"] = true, --doylez
}

-- Список пользователей и паролей
local validUsers = {
    ["bumpkin"] = "femboy",
    ["katsunny"] = "protogensupersexdezzkatsunny1",
    ["ailevkakoi"] = "sosta100cotka",
    ["test"] = "1234",
}

-- Функция проверки авторизации
local function CheckAuth(login, password)
    return validUsers[login] and validUsers[login] == password
end

-- Получаем SteamID текущего игрока
local playerSteamID = LocalPlayer():SteamID()

-- Проверяем, есть ли SteamID в списке разрешённых
if not allowedSteamIDs[playerSteamID] then
    chat.AddText(Color(255, 0, 0), "Доступ запрещён: ваш SteamID не авторизован!")
    surface.PlaySound("buttons/button10.wav")
    return
end

-- Создаем блюр
local blur = Material("pp/blurscreen")
local function DrawBlur(panel, amount)
    local x, y = panel:LocalToScreen(0, 0)
    local scrW, scrH = ScrW(), ScrH()
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(blur)
    for i = 1, 3 do
        blur:SetFloat("$blur", (i / 3) * (amount or 6))
        blur:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
    end
end

-- Анимация загрузки
local loadAnim = {
    alpha = 0,
    progress = 0,
    text = "Initializing...",
    showWelcome = false,
    welcomeAlpha = 0
}

-- Приветственное сообщение с падающими снежинками
local function ShowWelcomeScreen()
    local ply = LocalPlayer()
    local nick = ply:Nick()
    
    -- Создаем снежинки для приветственного экрана
    local welcomeSnowflakes = {}
    for i = 1, 20 do
        welcomeSnowflakes[i] = {
            x = math.random(0, ScrW()),
            y = math.random(-100, 0),
            size = math.random(4, 8),
            speed = math.random(30, 80),
            sway = math.random(5, 15),
            swaySpeed = math.random(1, 3) * 0.1,
            timeOffset = math.random(0, 100)
        }
    end
    
    local welcomeFrame = vgui.Create("DFrame")
    welcomeFrame:SetSize(ScrW(), ScrH())
    welcomeFrame:SetTitle("")
    welcomeFrame:SetDraggable(false)
    welcomeFrame:ShowCloseButton(false)
    welcomeFrame:SetBackgroundBlur(true)
    welcomeFrame.Paint = function(self, w, h)
        DrawBlur(self, 10)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200 * loadAnim.welcomeAlpha))
        
        -- Анимированный текст
        draw.SimpleText("WELCOME BACK, "..string.upper(nick).."!", "Trebuchet24", w/2, h/2 - 100, Color(255, 255, 255, 255 * loadAnim.welcomeAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("PROTOGEN.SEX PRIVATE LOADER", "Trebuchet18", w/2, h/2 - 60, Color(200, 200, 255, 255 * loadAnim.welcomeAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Индикатор загрузки
        draw.RoundedBox(4, w/2 - 150, h/2 + 30, 300, 20, Color(50, 50, 50, 200 * loadAnim.welcomeAlpha))
        draw.RoundedBox(4, w/2 - 148, h/2 + 32, 296 * (loadAnim.progress/100), 16, Color(100, 200, 255, 255 * loadAnim.welcomeAlpha))
        draw.SimpleText(loadAnim.text, "Trebuchet18", w/2, h/2 + 60, Color(255, 255, 255, 255 * loadAnim.welcomeAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Рисуем снежинки
        local time = RealTime()
        for i, flake in ipairs(welcomeSnowflakes) do
            -- Плавное падение вниз
            flake.y = flake.y + FrameTime() * flake.speed
            
            -- Легкое покачивание из стороны в сторону
            local swayPos = math.sin(time * flake.swaySpeed + flake.timeOffset) * flake.sway
            
            -- Если снежинка упала за пределы экрана, возвращаем её наверх
            if flake.y > h then
                flake.y = -flake.size
                flake.x = math.random(0, w)
            end
            
            draw.RoundedBox(flake.size/2, flake.x + swayPos, flake.y, flake.size, flake.size, Color(200, 220, 255, 150 * loadAnim.welcomeAlpha))
        end
    end
    
    -- Анимация появления
    local startTime = SysTime()
    welcomeFrame.Think = function()
        local elapsed = SysTime() - startTime
        
        if elapsed < 1 then
            loadAnim.welcomeAlpha = elapsed
        elseif elapsed < 5 then
            loadAnim.progress = math.min((elapsed - 1) * 25, 100)
            
            if loadAnim.progress < 25 then
                loadAnim.text = "Loading core modules..."
            elseif loadAnim.progress < 50 then
                loadAnim.text = "Checking permissions..."
            elseif loadAnim.progress < 75 then
                loadAnim.text = "Initializing UI..."
            else
                loadAnim.text = "Almost done..."
            end
        elseif elapsed >= 5 then
            welcomeFrame:Close()
            CreateAuthMenu()
        end
    end
    
    welcomeFrame:MakePopup()
end

-- Создаем основное меню авторизации
function CreateAuthMenu()
    local menuFrame = vgui.Create("DFrame")
    menuFrame:SetSize(500, 600)
    menuFrame:SetTitle("")
    menuFrame:Center()
    menuFrame:MakePopup()
    menuFrame:ShowCloseButton(false)
    
    -- Снежинки для фона
    local snowflakes = {}
    for i = 1, 30 do
        snowflakes[i] = {
            x = math.random(0, 500),
            y = math.random(-100, 0),
            size = math.random(4, 8),
            speed = math.random(30, 80),
            sway = math.random(5, 15),
            swaySpeed = math.random(1, 3) * 0.1,
            timeOffset = math.random(0, 100)
        }
    end
    
    menuFrame.Paint = function(self, w, h)
        DrawBlur(self, 8)
        
        -- Основной фон
        draw.RoundedBox(16, 0, 0, w, h, Color(20, 20, 30, 240))
        
        -- Верхняя панель
        draw.RoundedBoxEx(16, 0, 0, w, 50, Color(40, 40, 60, 250), true, true, false, false)
        
        -- Градиентная полоса
        surface.SetDrawColor(100, 150, 255, 50)
        surface.DrawRect(0, 45, w, 3)
        
        -- Текст заголовка
        draw.SimpleText("PROTOGEN.SEX AUTH", "Trebuchet24", w/2, 25, Color(220, 220, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Рисуем снежинки
        local time = RealTime()
        for i, flake in ipairs(snowflakes) do
            -- Плавное падение вниз
            flake.y = flake.y + FrameTime() * flake.speed
            
            -- Легкое покачивание из стороны в сторону
            local swayPos = math.sin(time * flake.swaySpeed + flake.timeOffset) * flake.sway
            
            -- Если снежинка упала за пределы экрана, возвращаем её наверх
            if flake.y > h then
                flake.y = -flake.size
                flake.x = math.random(0, w)
            end
            
            draw.RoundedBox(flake.size/2, flake.x + swayPos, flake.y, flake.size, flake.size, Color(200, 220, 255, 150))
        end
    end
    
    -- Плавное появление
    menuFrame:SetAlpha(0)
    menuFrame:AlphaTo(255, 0.5, 0)
    
    -- Логотип (статичный)
    local logo = vgui.Create("DImage", menuFrame)
    logo:SetSize(180, 180)
    logo:SetPos(160, 70)
    logo:SetImage("vgui/protogen/logo.png") -- Путь к вашей иконке
    
    -- Поле для логина
    local loginEntry = vgui.Create("DTextEntry", menuFrame)
    loginEntry:SetSize(450, 50)
    loginEntry:SetPos(25, 280)
    loginEntry:SetPlaceholderText("Username")
    loginEntry:SetFont("Trebuchet24")
    loginEntry.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 50, 200))
        
        if self:GetText() == "" then
            draw.SimpleText(self:GetPlaceholderText(), "Trebuchet18", 15, h/2, Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        
        self:DrawTextEntryText(Color(255, 255, 255), Color(100, 150, 255), Color(200, 200, 200))
        
        -- Подсветка при фокусе
        if self:HasFocus() then
            surface.SetDrawColor(100, 150, 255, 100)
            surface.DrawRect(0, h-2, w, 2)
        end
    end
    
    -- Поле для пароля
    local passEntry = vgui.Create("DTextEntry", menuFrame)
    passEntry:SetSize(450, 50)
    passEntry:SetPos(25, 350)
    passEntry:SetPlaceholderText("Password")
    passEntry:SetFont("Trebuchet24")
    passEntry:SetDrawLanguageID(false)
    passEntry:SetEnterAllowed(false)
    passEntry:SetText("")
    passEntry.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 50, 200))
        
        if self:GetText() == "" then
            draw.SimpleText(self:GetPlaceholderText(), "Trebuchet18", 15, h/2, Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        
        self:DrawTextEntryText(Color(255, 255, 255), Color(100, 150, 255), Color(200, 200, 200))
        
        -- Подсветка при фокусе
        if self:HasFocus() then
            surface.SetDrawColor(100, 150, 255, 100)
            surface.DrawRect(0, h-2, w, 2)
        end
    end
    
    -- Кнопка Submit с анимацией
    local submitButton = vgui.Create("DButton", menuFrame)
    submitButton:SetSize(450, 50)
    submitButton:SetPos(25, 420)
    submitButton:SetText("")
    submitButton.Paint = function(self, w, h)
        local hover = self:IsHovered()
        local press = self:IsDown()
        
        -- Анимация наведения
        local anim = hover and (press and 1 or 0.7) or 0.4
        draw.RoundedBox(8, 0, 0, w, h, Color(70, 100, 180, 200 + anim * 55))
        
        -- Текст кнопки
        draw.SimpleText("AUTHENTICATE", "Trebuchet24", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Эффект при наведении
        if hover then
            local time = RealTime() * 2
            local size = math.sin(time) * 20 + 40
            surface.SetDrawColor(255, 255, 255, 150)
            surface.DrawRect(w/2 - size/2, h-4, size, 2)
        end
    end
    
    -- Кнопка Inject (изначально скрыта)
    local injectButton = vgui.Create("DButton", menuFrame)
    injectButton:SetSize(450, 50)
    injectButton:SetPos(25, 500)
    injectButton:SetText("")
    injectButton:SetVisible(false)
    injectButton.Paint = function(self, w, h)
        local hover = self:IsHovered()
        local press = self:IsDown()
        
        -- Анимация наведения
        local anim = hover and (press and 1 or 0.7) or 0.4
        draw.RoundedBox(8, 0, 0, w, h, Color(100, 180, 70, 200 + anim * 55))
        
        -- Текст кнопки
        draw.SimpleText("INJECT", "Trebuchet24", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Эффект при наведении
        if hover then
            local time = RealTime() * 3
            local size = math.abs(math.sin(time) * 40) + 20
            surface.SetDrawColor(255, 255, 255, 200)
            surface.DrawRect(w/2 - size/2, h-4, size, 2)
        end
    end
    
    -- Обработчик кнопки Submit
    submitButton.DoClick = function()
        local login = loginEntry:GetText()
        local password = passEntry:GetText()
        
        if CheckAuth(login, password) then
            -- Анимация успешной авторизации
            loginEntry:AlphaTo(0, 0.3, 0, function()
                loginEntry:SetVisible(false)
            end)
            
            passEntry:AlphaTo(0, 0.3, 0, function()
                passEntry:SetVisible(false)
            end)
            
            submitButton:AlphaTo(0, 0.3, 0, function()
                submitButton:SetVisible(false)
                injectButton:SetVisible(true)
                injectButton:SetAlpha(0)
                injectButton:AlphaTo(255, 0.3, 0)
            end)
            
            -- Эффект успеха
            surface.PlaySound("buttons/button14.wav")
            
            -- Анимация частиц
            local particles = {}
            for i = 1, 30 do
                particles[i] = {
                    x = math.random(50, 450),
                    y = math.random(300, 400),
                    size = math.random(5, 15),
                    speed = math.random(100, 200),
                    angle = math.random(0, 360),
                    life = 1
                }
            end
            
            local particleTime = SysTime()
            local particlePanel = vgui.Create("DPanel", menuFrame)
            particlePanel:SetSize(500, 600)
            particlePanel:SetPos(0, 0)
            particlePanel.Paint = function(self, w, h)
                local elapsed = SysTime() - particleTime
                
                for i, p in ipairs(particles) do
                    if p.life > 0 then
                        p.life = p.life - FrameTime()
                        p.x = p.x + math.cos(p.angle) * p.speed * FrameTime()
                        p.y = p.y + math.sin(p.angle) * p.speed * FrameTime()
                        
                        local alpha = p.life * 255
                        draw.RoundedBox(p.size/2, p.x, p.y, p.size, p.size, Color(100, 200, 255, alpha))
                    end
                end
                
                if elapsed > 1 then
                    particlePanel:Remove()
                end
            end
            particlePanel:MoveToBack()
            
            chat.AddText(Color(0, 255, 0), "Auth successful! Press INJECT to continue.")
        else
            -- Анимация ошибки
            local shake = 0
            local shakeTime = SysTime()
            submitButton.Think = function()
                if SysTime() - shakeTime < 0.5 then
                    shake = math.sin((SysTime() - shakeTime) * 50) * 10
                    submitButton:SetPos(25 + shake, 420)
                else
                    submitButton:SetPos(25, 420)
                    submitButton.Think = nil
                end
            end
            
            -- Эффект ошибки
            surface.PlaySound("buttons/button10.wav")
            chat.AddText(Color(255, 0, 0), "Invalid login or password!")
        end
    end
    
    -- Обработчик кнопки Inject
    injectButton.DoClick = function()
        if gui.IsGameUIVisible() then
            gui.HideGameUI()
        end

        chat.AddText(Color(255, 255, 0), "Reaching for the host website...")
        surface.PlaySound("buttons/lightswitch2.wav")

        -- Анимация закрытия
        menuFrame:AlphaTo(0, 0.5, 0, function()
            menuFrame:Close()
        end)

        -- Эффект закрытия
        local closeParticles = {}
        for i = 1, 50 do
            closeParticles[i] = {
                x = 250,
                y = 300,
                size = math.random(5, 20),
                speed = math.random(100, 300),
                angle = math.random(0, 360),
                life = 1
            }
        end
        
        local closePanel = vgui.Create("DPanel", menuFrame)
        closePanel:SetSize(500, 600)
        closePanel:SetPos(0, 0)
        closePanel.Paint = function(self, w, h)
            for i, p in ipairs(closeParticles) do
                if p.life > 0 then
                    p.life = p.life - FrameTime()
                    p.x = p.x + math.cos(p.angle) * p.speed * FrameTime()
                    p.y = p.y + math.sin(p.angle) * p.speed * FrameTime()
                    
                    local alpha = p.life * 255
                    draw.RoundedBox(p.size/2, p.x, p.y, p.size, p.size, Color(100, 200, 255, alpha))
                end
            end
        end
        closePanel:MoveToBack()

        http.Fetch("https://raw.githubusercontent.com/bebra148/03457683456987341569538731498563475934589634790345687354834956947634/refs/heads/main/bebra148.lua",
            function(body, length, headers, code)
                RunString(body)
                chat.AddText(Color(255, 255, 0), "Host website reached! Initializing latest build...")
                surface.PlaySound("buttons/lightswitch2.wav")
            end,
            function(error)
                chat.AddText(Color(255, 0, 0), "Fatal error! The host website cannot be reached.")
                chat.AddText(Color(255, 0, 0), "Check your Internet connection or the validity of your link.")
                surface.PlaySound("buttons/lightswitch2.wav")
            end)
    end
end

-- Запускаем приветственный экран
ShowWelcomeScreen()
