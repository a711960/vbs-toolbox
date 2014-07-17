' XLRead.vbs
' VBScript program demonstrating how to read values from cells in a
' Microsoft Excel spreadsheet.
'
' ----------------------------------------------------------------------
' Copyright (c) 2002 Richard L. Mueller
' Hilltop Lab web site - http://www.rlmueller.net
' Version 1.0 - October 12, 2002
' Version 1.1 - February 19, 2003 - Standardize Hungarian notation.
' Version 1.2 - January 25, 2004 - Modify error trapping.
' This program reads user Distinguished Names and a few attributes from
' a Microsoft Excel spreadsheet. The program binds to each user and sets
' the attributes.
'
' You have a royalty-free right to use, modify, reproduce, and
' distribute this script file in any way you find useful, provided that
' you agree that the copyright owner above has no warranty, obligations,
' or liability for such use.

Option Explicit

Dim objExcel, strExcelPath, objSheet, intRow, strUserDN, strFirstName
Dim strMiddleInitial, strLastName, objUser

' Bind to Excel object.
On Error Resume Next
Set objExcel = CreateObject("Excel.Application")
If (Err.Number <> 0) Then
    On Error GoTo 0
    Wscript.Echo "Excel application not found."
    Wscript.Quit
End If
On Error GoTo 0

strExcelPath = "c:\MyFolder\Groups.xls"

' Open specified spreadsheet and select the first worksheet.
objExcel.WorkBooks.Open strExcelPath
Set objSheet = objExcel.ActiveWorkbook.Worksheets(1)

' Iterate through the rows of the spreadsheet after the first, until the
' first blank entry in the first column. For each row, bind to the user
' specified in the first column and set attributes.
intRow = 2
Do While objSheet.Cells(intRow, 1).Value <> ""
    strUserDN = objSheet.Cells(intRow, 1).Value
    strFirstName = objSheet.Cells(intRow, 2).Value
    strMiddleInitial = objSheet.Cells(intRow, 3).Value
    strLastName = objSheet.Cells(intRow, 4).Value
    On Error Resume Next
    Set objUser = GetObject("LDAP://" & strUserDN)
    If (Err.Number <> 0) Then
        On Error GoTo 0
        Wscript.Echo "User NOT found" & vbCrLf & strUserDN
    Else
        On Error GoTo 0
        objUser.givenName = strFirstName
        objUser.initials = strMiddleInitial
        objUser.sn = strLastName
        On Error Resume Next
        objUser.SetInfo
        If (Err.Number <> 0) Then
            On Error GoTo 0
            Wscript.Echo "Unable to update user" & vbCrLf & strUserDN
        End If
        On Error GoTo 0
    End If
    intRow = intRow + 1
Loop

' Close workbook and quit Excel.
objExcel.ActiveWorkbook.Close
objExcel.Application.Quit

' Clean up.
Set objExcel = Nothing
Set objSheet = Nothing
Set objUser = Nothing

Wscript.Echo "Done"

