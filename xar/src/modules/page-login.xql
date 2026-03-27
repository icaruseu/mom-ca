xquery version "3.1";

(:~
 : Login page — handles both GET (show form) and POST (authenticate).
 : On successful POST, creates session and redirects to home.
 :)

let $method := request:get-method()
let $error :=
    if ($method = 'POST') then
        let $username := request:get-parameter('username', '')
        let $password := request:get-parameter('password', '')
        return
            if ($username = '' or $password = '') then
                'Please enter email and password.'
            else if (xmldb:login('/db', $username, $password, true())) then
                let $_ := session:create()
                let $_ := session:set-attribute('mom.user', $username)
                let $_ := session:set-attribute('mom.pass', $password)
                let $sid := session:get-id()
                let $_ := response:set-header('Set-Cookie',
                    'JSESSIONID=' || $sid || '; Path=/; HttpOnly; SameSite=Lax')
                let $_ := response:redirect-to(xs:anyURI('/mom/home'))
                return ()
            else
                'Invalid username or password.'
    else ()

return
<div style="max-width:400px;margin:2rem auto">
    <div class="card">
        <div class="card-header">
            <h2 style="margin:0">Login</h2>
        </div>
        <div class="card-body">
            {if ($error and $error != '') then
                <div style="padding:8px 12px; border-radius:4px; margin-bottom:var(--space-md); background:#fce4e4; color:#8b2500;">
                    {$error}
                </div>
            else ()}

            <form method="POST" action="/mom/login">
                <div style="margin-bottom: var(--space-md);">
                    <label for="username" style="display:block; margin-bottom:4px; font-weight:600;">Email</label>
                    <input id="username" name="username" type="text" placeholder="you@example.com"
                           autocomplete="username"
                           style="width:100%; padding:8px 12px; border:1px solid var(--color-border); border-radius:4px;" />
                </div>
                <div style="margin-bottom: var(--space-md);">
                    <label for="password" style="display:block; margin-bottom:4px; font-weight:600;">Password</label>
                    <input id="password" name="password" type="password" placeholder="Password"
                           autocomplete="current-password"
                           style="width:100%; padding:8px 12px; border:1px solid var(--color-border); border-radius:4px;" />
                </div>
                <button type="submit" class="btn btn--primary" style="width:100%; justify-content:center;">Login</button>
            </form>

            <p class="text-small" style="margin-top: var(--space-md);">
                <a href="request-password">Forgot your password?</a>
            </p>
        </div>
    </div>
</div>
