<div class="context-block">
    <div class="box-header"><h1 class="context-title">Exponential Layouts Setup</h1></div>
    <div class="box-ml">
        {if $message}<div class="message-feedback">{$message|wash}</div>{/if}
        {if $error}<div class="message-error">{$error|wash}</div>{/if}

        <p>Detected database type: <code>{$db_type|wash}</code></p>

        {if $schema_file}
            <p>Schema file: <code>{$schema_file|wash}</code></p>
            <form method="post" action={'explayouts_ui/setup'|ezurl}>
                <input class="defaultbutton" type="submit" name="InstallSchema" value="Install / update schema" onclick="return confirm('Run the schema DDL? Existing data in these tables will not be removed because CREATE TABLE IF NOT EXISTS is used.');" />
            </form>
        {else}
            <p>Could not determine a supported schema file for this database.</p>
        {/if}

        <p><a href={'explayouts_ui/layout_list'|ezurl} class="button">Back to layouts</a></p>
    </div>
</div>
