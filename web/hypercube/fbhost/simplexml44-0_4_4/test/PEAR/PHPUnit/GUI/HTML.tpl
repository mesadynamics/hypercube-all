<html>
    <head>
        <STYLE type="text/css">
        
            body, td {
                background-color: lightgrey;
            }
        
            table.outline, outlineFailure {
                background-color: black;
                border-width: 1px;
            }
            
            td {
                padding: 2px;
            }
            
            th {
                text-align: left;
                color: white;
                background-color: black;
            }
            
            .success {
                background-color: lightgreen;
            }
            
            .failure {
                background-color: orange;
            }
            .info {
                padding: 2px;
                color: orange;
            }
            
        </STYLE>
    </head>
    <body>
        <form action="<?=$_SERVER['PHP_SELF'] ?>" method="post" name="optionsForm">
            <table align="center" class="outline" width="70%">
                <tr>
                    <th colspan="10">
                        Options
                    </th>
                </tr>
                <tr>
                    <td colspan="10">
                        <input type="checkbox" onClick="unCheckAll()" name="allChecked">
                        (un)check all
                        &nbsp; &nbsp;
                        show OK <input type="checkbox" name="showOK" <?=@$_REQUEST['showOK']?'checked':''?>>
                        &nbsp; &nbsp;
                        <input type="submit" name="submitted" value="run tests">
                    </td>
                </tr>
                
                <? foreach($suiteResults as $aResult): ?>
                    <tr>
                        <th colspan="10">
                            <input type="checkbox" name="<?=$aResult['name'] ?>" <?=@$_REQUEST[$aResult['name']]?'checked':'' ?>>
                            <?=$aResult['name'] ?>
                            &nbsp;
                            <? if (isset($aResult['addInfo'])): ?>
                                <font class="info"><?=@$aResult['addInfo'] ?></font>
                            <? endif ?>
                        </th>
                    </tr>

                    <? if(@$aResult['percent']): ?>
                        <tr>
                            <td colspan="10" nowrap="nowrap">
                                <table style="width:100%; padding:2px;" cellspacing="0" cellspan="0" cellpadding="0">
                                    <tr>
                                        <td width="<?=$aResult['percent'] ?>%" class="success" align="center" style="padding:0;">
                                            <?=$aResult['percent']?$aResult['percent'].'%':'' ?>
                                        </td>
                                        <td width="<?=100-$aResult['percent'] ?>%" class="failure" align="center" style="padding:0;">
                                            <?=(100-$aResult['percent'])?(100-$aResult['percent'].'%'):'' ?>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    <? endif ?>

                    <? if(@$aResult['counts']): ?>
                        <tr>
                            <td colspan="10">
                                <? foreach($aResult['counts'] as $aCount=>$value): ?>
                                    <?=$aCount ?>s = <?=$value ?> &nbsp; &nbsp; &nbsp; &nbsp; 
                                <? endforeach ?>
                            </td>
                        </tr>
                    <? endif ?>

                    <? if(isset($aResult['results']['failures']) && sizeof($aResult['results']['failures']))
                        foreach($aResult['results']['failures'] as $aFailure): ?>
                        <tr>
                            <td class="failure"><?=$aFailure['testName'] ?></td>
                            <td class="failure">
                                <? if(isset($aFailure['message']) && $aFailure['message']): ?>
                                    <?=$aFailure['message'] ?>
                                <? else: ?>
                                    <table class="outlineFailure">
                                        <tr>
                                            <td>expected</td>
                                            <td><?=$aFailure['expected'] ?></td>
                                        </tr>
                                        <tr>
                                            <td>actual</td>
                                            <td><?=$aFailure['actual'] ?></td>
                                        </tr>
                                    </table>
                                <? endif ?>
                            </td>
                        </tr>
                    <? endforeach ?>

                    <? if(isset($aResult['results']['errors']) && sizeof($aResult['results']['errors']))
                        foreach($aResult['results']['errors'] as $aError): ?>
                        <tr>
                            <td class="failure"><?=$aError['testName'] ?></td>
                            <td class="failure">
                                <?=$aError['message'] ?>
                            </td>
                        </tr>
                    <? endforeach ?>

                    <? if(isset($aResult['results']['passed']) && sizeof($aResult['results']['passed']))
                        foreach($aResult['results']['passed'] as $aPassed): ?>
                        <tr>
                            <td class="success"><?=$aPassed['testName'] ?></td>
                            <td class="success"><b>OK</b></td>
                        </tr>
                    <? endforeach ?>

                <? endforeach ?>
            </table>
        </form>
        
        <script>
            var allSuiteNames = new Array();
            <? foreach($suiteResults as $aResult): ?>
                allSuiteNames[allSuiteNames.length] = "<?=$aResult['name'] ?>";
            <? endforeach ?>
            function unCheckAll()
            {
                _checked = document.optionsForm.allChecked.checked;
                for (i=0;i<allSuiteNames.length;i++) {
                    document.optionsForm[allSuiteNames[i]].checked = _checked;
                }
            }
        </script>
        
    </body>
</html>
