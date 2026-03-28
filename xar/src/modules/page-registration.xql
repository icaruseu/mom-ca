xquery version "3.1";

(:~
 : User registration page.
 : GET  — shows registration form
 : POST — creates user account and redirects to success page
 :)

declare namespace xrx = "http://www.monasterium.net/NS/xrx";

let $method := request:get-method()
let $error :=
    if ($method = 'POST') then
        let $email := normalize-space(request:get-parameter('email', ''))
        let $password := request:get-parameter('password', '')
        let $password2 := request:get-parameter('password2', '')
        let $firstname := normalize-space(request:get-parameter('firstname', ''))
        let $name := normalize-space(request:get-parameter('name', ''))
        let $institution := normalize-space(request:get-parameter('institution', ''))
        let $info := normalize-space(request:get-parameter('info', ''))
        return
            (: Validation :)
            if ($email = '') then 'Email is required.'
            else if (not(matches($email, '^[^@]+@[^@]+\.[^@]+$'))) then 'Please enter a valid email address.'
            else if ($firstname = '') then 'First name is required.'
            else if ($name = '') then 'Last name is required.'
            else if (string-length($password) lt 6) then 'Password must be at least 6 characters.'
            else if ($password ne $password2) then 'Passwords do not match.'
            else if (sm:user-exists($email)) then 'An account with this email already exists.'
            else
                (: Create eXist-db user account :)
                let $_ := sm:create-account($email, $password, 'guest', ('atom'))

                (: Create user data collection :)
                let $user-encoded := xmldb:encode($email)
                let $user-path := '/db/mom-data/xrx.user/' || $user-encoded
                let $_ := if (not(xmldb:collection-available($user-path))) then
                    xmldb:create-collection('/db/mom-data/xrx.user', $user-encoded) else ()

                (: Store user profile XML :)
                let $user-xml :=
                    <xrx:user xmlns:xrx="http://www.monasterium.net/NS/xrx">
                        <xrx:username>{$email}</xrx:username>
                        <xrx:password/>
                        <xrx:firstname>{$firstname}</xrx:firstname>
                        <xrx:name>{$name}</xrx:name>
                        <xrx:email>{$email}</xrx:email>
                        <xrx:moderator/>
                        <xrx:street/>
                        <xrx:zip/>
                        <xrx:town/>
                        <xrx:phone/>
                        <xrx:institution>{$institution}</xrx:institution>
                        <xrx:info>{$info}</xrx:info>
                        <xrx:storage>
                            <xrx:saved_list/>
                            <xrx:bookmark_list/>
                        </xrx:storage>
                    </xrx:user>
                let $_ := xmldb:store($user-path, $user-encoded || '.xml', $user-xml)

                (: Set permissions — user owns their data :)
                let $_ := sm:chown(xs:anyURI($user-path || '/' || $user-encoded || '.xml'), $email)
                let $_ := sm:chmod(xs:anyURI($user-path || '/' || $user-encoded || '.xml'), 'rwxr-x---')
                let $_ := sm:chown(xs:anyURI($user-path), $email)

                (: Create mycollection and charter sub-collections :)
                let $_ := xmldb:create-collection($user-path, 'metadata.mycollection')
                let $_ := xmldb:create-collection($user-path, 'metadata.charter')
                let $_ := xmldb:create-collection($user-path, 'metadata.bookmark-notes')

                (: Auto-login :)
                let $_ := xmldb:login('/db', $email, $password, true())
                let $_ := session:create()
                let $_ := session:set-attribute('mom.user', $email)
                let $_ := session:set-attribute('mom.pass', $password)
                let $sid := session:get-id()
                let $_ := response:set-header('Set-Cookie',
                    'JSESSIONID=' || $sid || '; Path=/; HttpOnly; SameSite=Lax')

                (: Redirect to success :)
                let $_ := response:redirect-to(xs:anyURI('/mom/registration-successful'))
                return ()
    else ()

return
<div style="max-width:500px;margin:2rem auto">
    <div class="card">
        <div class="card-header">
            <h2 style="margin:0">Create Account</h2>
        </div>
        <div class="card-body">
            {if ($error and $error != '') then
                <div style="padding:8px 12px; border-radius:4px; margin-bottom:var(--space-md); background:#fce4e4; color:#8b2500;">
                    {$error}
                </div>
            else ()}

            <form method="POST" action="/mom/registration">
                <div style="display:grid; grid-template-columns:1fr 1fr; gap:var(--space-sm); margin-bottom:var(--space-md);">
                    <div>
                        <label style="display:block; margin-bottom:4px; font-weight:600; font-size:0.85rem;">First Name *</label>
                        <input name="firstname" type="text" required="required" value="{request:get-parameter('firstname', '')}"
                               style="width:100%; padding:8px 12px; border:1px solid var(--color-border); border-radius:4px;"/>
                    </div>
                    <div>
                        <label style="display:block; margin-bottom:4px; font-weight:600; font-size:0.85rem;">Last Name *</label>
                        <input name="name" type="text" required="required" value="{request:get-parameter('name', '')}"
                               style="width:100%; padding:8px 12px; border:1px solid var(--color-border); border-radius:4px;"/>
                    </div>
                </div>

                <div style="margin-bottom:var(--space-md);">
                    <label style="display:block; margin-bottom:4px; font-weight:600; font-size:0.85rem;">Email *</label>
                    <input name="email" type="email" required="required" placeholder="you@example.com"
                           value="{request:get-parameter('email', '')}"
                           style="width:100%; padding:8px 12px; border:1px solid var(--color-border); border-radius:4px;"/>
                </div>

                <div style="display:grid; grid-template-columns:1fr 1fr; gap:var(--space-sm); margin-bottom:var(--space-md);">
                    <div>
                        <label style="display:block; margin-bottom:4px; font-weight:600; font-size:0.85rem;">Password *</label>
                        <input name="password" type="password" required="required" minlength="6"
                               placeholder="Min. 6 characters"
                               style="width:100%; padding:8px 12px; border:1px solid var(--color-border); border-radius:4px;"/>
                    </div>
                    <div>
                        <label style="display:block; margin-bottom:4px; font-weight:600; font-size:0.85rem;">Repeat Password *</label>
                        <input name="password2" type="password" required="required"
                               style="width:100%; padding:8px 12px; border:1px solid var(--color-border); border-radius:4px;"/>
                    </div>
                </div>

                <div style="margin-bottom:var(--space-md);">
                    <label style="display:block; margin-bottom:4px; font-weight:600; font-size:0.85rem;">Institution</label>
                    <input name="institution" type="text" value="{request:get-parameter('institution', '')}"
                           placeholder="University, Archive, etc."
                           style="width:100%; padding:8px 12px; border:1px solid var(--color-border); border-radius:4px;"/>
                </div>

                <div style="margin-bottom:var(--space-md);">
                    <label style="display:block; margin-bottom:4px; font-weight:600; font-size:0.85rem;">About you</label>
                    <textarea name="info" rows="3" placeholder="Tell us about your research interests..."
                              style="width:100%; padding:8px 12px; border:1px solid var(--color-border); border-radius:4px; font-family:inherit;">{request:get-parameter('info', '')}</textarea>
                </div>

                <button type="submit" class="btn btn--primary" style="width:100%; justify-content:center;">Create Account</button>
            </form>

            <p class="text-small text-muted" style="margin-top:var(--space-md); text-align:center;">
                Already have an account? <a href="login">Login</a>
            </p>
        </div>
    </div>
</div>
