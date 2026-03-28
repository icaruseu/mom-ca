xquery version "3.1";

(:~ Registration success page :)

let $user := try { string(session:get-attribute('mom.user')) } catch * { '' }

return
<div style="max-width:500px;margin:var(--space-xxl) auto; text-align:center;">
    <div class="card">
        <div class="card-body" style="padding:var(--space-xl);">
            <div style="font-size:3rem; margin-bottom:var(--space-md);">&#x2705;</div>
            <h2>Welcome to Monasterium!</h2>
            <p class="text-muted" style="margin-bottom:var(--space-lg);">
                Your account {if ($user ne '') then <strong>{$user}</strong> else ()} has been created successfully.
                You are now logged in and can start exploring charters.
            </p>
            <div style="display:flex; gap:var(--space-sm); justify-content:center;">
                <a href="/mom/home" class="btn btn--primary">Go to Home</a>
                <a href="/mom/fonds" class="btn">Browse Archives</a>
            </div>
        </div>
    </div>
</div>
