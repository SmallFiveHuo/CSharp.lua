﻿-- Generated by CSharp.lua Compiler 1.0.0.0
local System = System;
local Linq = System.Linq.Enumerable;
System.namespace("CSharpLua", function (namespace) 
    namespace.class("PartialTypeDeclaration", function (namespace) 
        local CompareTo;
        CompareTo = function (this, other) 
            return #this.CompilationUnit.FilePath:CompareTo(#other.CompilationUnit.FilePath);
        end;
        return {
            __inherits__ = {
                System.IComparable_1(CSharpLua.PartialTypeDeclaration)
            }, 
            CompareTo = CompareTo
        };
    end);
    namespace.class("LuaSyntaxGenerator", function (namespace) 
        namespace.class("SettingInfo", function (namespace) 
            local getIndent, setIndent, __ctor__;
            getIndent = function (this) 
                return this.indent_;
            end;
            setIndent = function (this, value) 
                if this.indent_ ~= value then
                    this.indent_ = value;
                    this.IndentString = System.String(32 --[[' ']], this.indent_);
                end
            end;
            __ctor__ = function (this) 
                setIndent(this, 4);
                this.HasSemicolon = true;
                this.IsNewest = true;
            end;
            return {
                HasSemicolon = False, 
                indent_ = 0, 
                IsNewest = False, 
                getIndent = getIndent, 
                setIndent = setIndent, 
                __ctor__ = __ctor__
            };
        end);
        local getEncoding, Create, Generate, GetOutFilePath, IsEnumExport, AddExportEnum, AddEnumDeclaration, CheckExportEnums, 
        AddPartialTypeDeclaration, CheckPartialTypes, GetSemanticModel, IsBaseType, GetMethodName, IsTypeEnable, GetExportTypes, ExportManifestFile, 
        AddTypeSymbol, CheckExtends, TryAddExtend, GetMemberMethodName, InternalGetMemberMethodName, GetExtensionMethodName, GetStaticClassMethodName, GetMethodNameFromIndex, 
        TryAddNewUsedName, GetSameNameMembers, MethodSymbolToString, MemberSymbolToString, GetSymbolWright, MemberSymbolCommonComparison, MemberSymbolBoolComparison, MemberSymbolComparison, 
        FillSameNameMembers, CheckRefactorNames, RefactorCurTypeSymbol, RefactorInterfaceSymbol, RefactorName, RefactorChildrensOverridden, UpdateName, GetRefactorName, 
        IsTypeNameUsed, CheckNewNameEnable, __init__, __ctor__;
        getEncoding = function () 
            return System.Text.Encoding.getUTF8();
        end;
        Create = function (this) 
            local luaCompilationUnits = System.List(CSharpLua.LuaAst.LuaCompilationUnitSyntax)();
            for _, syntaxTree in System.each(this.compilation_:getSyntaxTrees()) do
                local semanticModel = GetSemanticModel(this, syntaxTree);
                local compilationUnitSyntax = System.cast(Microsoft.CodeAnalysis.CSharp.Syntax.CompilationUnitSyntax, syntaxTree:GetRoot());
                local transfor = CSharpLua.LuaSyntaxNodeTransfor:new(1, this, semanticModel);
                local luaCompilationUnit = System.cast(CSharpLua.LuaAst.LuaCompilationUnitSyntax, compilationUnitSyntax:Accept(transfor, CSharpLua.LuaAst.LuaSyntaxNode));
                luaCompilationUnits:Add(luaCompilationUnit);
            end
            CheckExportEnums(this);
            CheckPartialTypes(this);
            CheckRefactorNames(this);
            return Linq.Where(luaCompilationUnits, function (i) return not i:getIsEmpty(); end);
        end;
        Generate = function (this, baseFolder, outFolder) 
            local modules = System.List(System.String)();
            for _, luaCompilationUnit in System.each(Create(this)) do
                local module;
                local default;
                default, module = GetOutFilePath(this, luaCompilationUnit.FilePath, baseFolder, outFolder, module);
                local outFile = default;
                System.using(function (writer) 
                    local rener = CSharpLua.LuaRenderer(this, writer);
                    luaCompilationUnit:Render(rener);
                end, System.IO.StreamWriter(outFile, false, getEncoding()));
                modules:Add(module);
            end
            ExportManifestFile(this, modules, outFolder);
        end;
        GetOutFilePath = function (this, inFilePath, folder_, output_, module) 
            local path = inFilePath:Remove(0, #folder_):TrimStart(System.IO.Path.DirectorySeparatorChar, 47 --[['/']]);
            local extend = System.IO.Path.GetExtension(path);
            path = path:Remove(#path - #extend, #extend);
            path = path:Replace(46 --[['.']], 95 --[['_']]);
            local outPath = System.IO.Path.Combine(output_, (path or "") .. ".lua" --[[LuaSyntaxGenerator.kLuaSuffix]]);
            local dir = System.IO.Path.GetDirectoryName(outPath);
            if not System.IO.Directory.Exists(dir) then
                System.IO.Directory.CreateDirectory(dir);
            end
            module = path:Replace(System.IO.Path.DirectorySeparatorChar, 46 --[['.']]);
            return outPath;
        end;
        IsEnumExport = function (this, enumTypeSymbol) 
            return this.exportEnums_:Contains(enumTypeSymbol);
        end;
        AddExportEnum = function (this, enumTypeSymbol) 
            this.exportEnums_:Add(enumTypeSymbol);
        end;
        AddEnumDeclaration = function (this, enumDeclaration) 
            this.enumDeclarations_:Add(enumDeclaration);
        end;
        CheckExportEnums = function (this) 
            for _, enumDeclaration in System.each(this.enumDeclarations_) do
                if IsEnumExport(this, enumDeclaration.FullName) then
                    enumDeclaration.IsExport = true;
                    enumDeclaration.CompilationUnit:AddTypeDeclarationCount();
                end
            end
        end;
        AddPartialTypeDeclaration = function (this, typeSymbol, node, luaNode, compilationUnit) 
            local list = CSharpLua.Utility.GetOrDefault1(this.partialTypes_, typeSymbol, nil, Microsoft.CodeAnalysis.INamedTypeSymbol, System.List(T));
            if list == nil then
                list = System.List(CSharpLua.PartialTypeDeclaration)();
                this.partialTypes_:Add(typeSymbol, list);
            end
            list:Add(System.create(CSharpLua.PartialTypeDeclaration(), function (default) 
                default.Symbol = typeSymbol;
                default.Node = node;
                default.LuaNode = luaNode;
                default.CompilationUnit = compilationUnit;
            end));
        end;
        CheckPartialTypes = function (this) 
            for _, typeDeclarations in System.each(this.partialTypes_:getValues()) do
                local major = Linq.Min(typeDeclarations);
                local transfor = CSharpLua.LuaSyntaxNodeTransfor:new(1, this, nil);
                transfor:AcceptPartialType(major, typeDeclarations);
            end
        end;
        GetSemanticModel = function (this, syntaxTree) 
            return this.compilation_:GetSemanticModel(syntaxTree);
        end;
        IsBaseType = function (this, type) 
            local syntaxTree = type:getSyntaxTree();
            local semanticModel = GetSemanticModel(this, syntaxTree);
            local symbol = Microsoft.CodeAnalysis.CSharp.CSharpExtensions.GetTypeInfo(semanticModel, type:getType()):getType();
            assert(symbol ~= nil);
            return symbol:getTypeKind() ~= 7 --[[TypeKind.Interface]];
        end;
        GetMethodName = function (this, symbol) 
            return GetMemberMethodName(this, symbol);
        end;
        IsTypeEnable = function (this, type) 
            if type:getTypeKind() == 5 --[[TypeKind.Enum]] then
                return IsEnumExport(this, type:ToString());
            end
            return true;
        end;
        GetExportTypes = function (this) 
            local allTypes = System.List(Microsoft.CodeAnalysis.INamedTypeSymbol)();
            if #this.types_ > 0 then
                this.types_:Sort(function (x, y) return x:ToString():CompareTo(y:ToString()); end);

                local typesList = System.List(System.List(Microsoft.CodeAnalysis.INamedTypeSymbol))();
                typesList:Add(this.types_);

                while true do
                    local parentTypes = System.HashSet(Microsoft.CodeAnalysis.INamedTypeSymbol)();
                    local lastTypes = CSharpLua.Utility.Last(typesList, System.List(T));
                    for _, type in System.each(lastTypes) do
                        if type:getBaseType() ~= nil then
                            if CSharpLua.Utility.IsFromCode(type:getBaseType()) then
                                parentTypes:Add(type:getBaseType());
                            end
                        end
                        for _, interfaceType in System.each(type:getInterfaces()) do
                            if CSharpLua.Utility.IsFromCode(interfaceType) then
                                parentTypes:Add(interfaceType);
                            end
                        end
                    end

                    if parentTypes:getCount() == 0 then
                        break;
                    end

                    typesList:Add(Linq.ToList(parentTypes));
                end

                typesList:Reverse();
                local types = Linq.Where(Linq.Distinct(Linq.SelectMany(typesList, function (i) return i; end, Microsoft.CodeAnalysis.INamedTypeSymbol)), IsTypeEnable);
                allTypes:AddRange(types);
            end
            return allTypes;
        end;
        ExportManifestFile = function (this, modules, outFolder) 
            local kDir = "dir";
            local kDirInitCode = "dir = (dir and #dir > 0) and (dir .. '.') or \"\"";
            local kRequire = "require";
            local kLoadCode = "local load = function(module) return require(dir .. module) end";
            local kLoad = "load";
            local kInit = "System.init";
            local kManifestFile = "manifest.lua";

            if #modules > 0 then
                modules:Sort();
                local types = GetExportTypes(this);
                if #types > 0 then
                    local functionExpression = CSharpLua.LuaAst.LuaFunctionExpressionSyntax();
                    functionExpression:AddParameter(CSharpLua.LuaAst.LuaIdentifierNameSyntax:new(1, kDir));
                    functionExpression:AddStatement1(CSharpLua.LuaAst.LuaIdentifierNameSyntax:new(1, kDirInitCode));

                    local requireIdentifier = CSharpLua.LuaAst.LuaIdentifierNameSyntax:new(1, kRequire);
                    local variableDeclarator = CSharpLua.LuaAst.LuaVariableDeclaratorSyntax(requireIdentifier);
                    variableDeclarator.Initializer = CSharpLua.LuaAst.LuaEqualsValueClauseSyntax(requireIdentifier);
                    functionExpression:AddStatement(CSharpLua.LuaAst.LuaLocalVariableDeclaratorSyntax(variableDeclarator));

                    functionExpression:AddStatement1(CSharpLua.LuaAst.LuaIdentifierNameSyntax:new(1, kLoadCode));
                    functionExpression:AddStatement(CSharpLua.LuaAst.LuaBlankLinesStatement.One);

                    local loadIdentifier = CSharpLua.LuaAst.LuaIdentifierNameSyntax:new(1, kLoad);
                    for _, module in System.each(modules) do
                        local argument = CSharpLua.LuaAst.LuaStringLiteralExpressionSyntax:new(1, CSharpLua.LuaAst.LuaIdentifierNameSyntax:new(1, module));
                        local invocation = CSharpLua.LuaAst.LuaInvocationExpressionSyntax:new(2, loadIdentifier, argument);
                        functionExpression:AddStatement1(invocation);
                    end
                    functionExpression:AddStatement(CSharpLua.LuaAst.LuaBlankLinesStatement.One);

                    local table = CSharpLua.LuaAst.LuaTableInitializerExpression();
                    for _, type in System.each(types) do
                        local typeName = this.XmlMetaProvider:GetTypeShortName(type);
                        table.Items:Add1(CSharpLua.LuaAst.LuaSingleTableItemSyntax(CSharpLua.LuaAst.LuaStringLiteralExpressionSyntax:new(1, typeName)));
                    end
                    functionExpression:AddStatement1(CSharpLua.LuaAst.LuaInvocationExpressionSyntax:new(2, CSharpLua.LuaAst.LuaIdentifierNameSyntax:new(1, kInit), table));

                    local luaCompilationUnit = CSharpLua.LuaAst.LuaCompilationUnitSyntax();
                    luaCompilationUnit.Statements:Add1(CSharpLua.LuaAst.LuaReturnStatementSyntax:new(1, functionExpression));

                    local outFile = System.IO.Path.Combine(outFolder, kManifestFile);
                    System.using(function (writer) 
                        local rener = CSharpLua.LuaRenderer(this, writer);
                        luaCompilationUnit:Render(rener);
                    end, System.IO.StreamWriter(outFile, false, getEncoding()));
                end
            end
        end;
        AddTypeSymbol = function (this, typeSymbol) 
            this.types_:Add(typeSymbol);
            CheckExtends(this, typeSymbol);
        end;
        CheckExtends = function (this, typeSymbol) 
            if typeSymbol:getSpecialType() ~= 1 --[[SpecialType.System_Object]] then
                if typeSymbol:getBaseType() ~= nil then
                    local super = typeSymbol:getBaseType();
                    TryAddExtend(this, super, typeSymbol);
                end
            end

            for _, super in System.each(typeSymbol:getAllInterfaces()) do
                TryAddExtend(this, super, typeSymbol);
            end
        end;
        TryAddExtend = function (this, super, children) 
            if CSharpLua.Utility.IsFromCode(super) then
                local set = CSharpLua.Utility.GetOrDefault1(this.extends_, super, nil, Microsoft.CodeAnalysis.INamedTypeSymbol, System.HashSet(T));
                if set == nil then
                    set = System.HashSet(Microsoft.CodeAnalysis.INamedTypeSymbol)();
                    this.extends_:Add(super, set);
                end
                set:Add(children);
            end
        end;
        GetMemberMethodName = function (this, symbol) 
            symbol = CSharpLua.Utility.CheckOriginalDefinition(symbol);
            local name = CSharpLua.Utility.GetOrDefault1(this.memberNames_, symbol, nil, Microsoft.CodeAnalysis.ISymbol, CSharpLua.LuaAst.LuaSymbolNameSyntax);
            if name == nil then
                local identifierName = InternalGetMemberMethodName(this, symbol);
                local symbolName = CSharpLua.LuaAst.LuaSymbolNameSyntax(identifierName);
                this.memberNames_:Add(symbol, symbolName);
                name = symbolName;
            end
            return name;
        end;
        InternalGetMemberMethodName = function (this, symbol) 
            local name = this.XmlMetaProvider:GetMethodMapName(symbol);
            if name ~= nil then
                return CSharpLua.LuaAst.LuaIdentifierNameSyntax:new(1, name);
            end

            if not CSharpLua.Utility.IsFromCode(symbol) then
                return CSharpLua.LuaAst.LuaIdentifierNameSyntax:new(1, symbol:getName());
            end

            if symbol:getIsExtensionMethod() then
                return GetExtensionMethodName(this, symbol);
            end

            if symbol:getIsStatic() then
                if symbol:getContainingType():getIsStatic() then
                    return GetStaticClassMethodName(this, symbol);
                end
            end

            if symbol:getContainingType():getTypeKind() == 7 --[[TypeKind.Interface]] then
                return CSharpLua.LuaAst.LuaIdentifierNameSyntax:new(1, symbol:getName());
            end

            while symbol:getOverriddenMethod() ~= nil do
                symbol = symbol:getOverriddenMethod();
            end

            local sameNameMembers = GetSameNameMembers(this, symbol);
            local symbolExpression = nil;
            local index = 0;
            for _, member in System.each(sameNameMembers) do
                if member:Equals(symbol) then
                    symbolExpression = CSharpLua.LuaAst.LuaIdentifierNameSyntax:new(1, symbol:getName());
                else
                    if not this.memberNames_:ContainsKey(member) then
                        local identifierName = CSharpLua.LuaAst.LuaIdentifierNameSyntax:new(1, member:getName());
                        this.memberNames_:Add(member, CSharpLua.LuaAst.LuaSymbolNameSyntax(identifierName));
                    end
                end
                if index > 0 then
                    if CSharpLua.Utility.IsFromCode(member:getContainingType()) then
                        this.refactorNames_:Add(member);
                    end
                end
                index = index + 1;
            end

            if symbolExpression == nil then
                System.throw(System.InvalidOperationException());
            end
            return symbolExpression;
        end;
        GetExtensionMethodName = function (this, symbol) 
            assert(symbol:getIsExtensionMethod());
            return GetStaticClassMethodName(this, symbol);
        end;
        GetStaticClassMethodName = function (this, symbol) 
            assert(symbol:getContainingType():getIsStatic());
            local sameNameMembers = symbol:getContainingType():GetMembers(symbol:getName());
            local symbolExpression = nil;
            local index = 0;
            for _, member in System.each(sameNameMembers) do
                local identifierName = GetMethodNameFromIndex(this, symbol, index);
                if member:Equals(symbol) then
                    symbolExpression = identifierName;
                else
                    if not this.memberNames_:ContainsKey(member) then
                        this.memberNames_:Add(member, CSharpLua.LuaAst.LuaSymbolNameSyntax(identifierName));
                    end
                end
                index = index + 1;
            end

            if symbolExpression == nil then
                System.throw(System.InvalidOperationException());
            end
            return symbolExpression;
        end;
        GetMethodNameFromIndex = function (this, symbol, index) 
            assert(index ~= - 1);
            if index == 0 then
                return CSharpLua.LuaAst.LuaIdentifierNameSyntax:new(1, symbol:getName());
            else
                while true do
                    local newName = (symbol:getName() or "") .. index;
                    if symbol:getContainingType():GetMembers(newName):getIsEmpty() then
                        if TryAddNewUsedName(this, symbol:getContainingType(), newName) then
                            return CSharpLua.LuaAst.LuaIdentifierNameSyntax:new(1, newName);
                        end
                    end
                    index = index + 1;
                end
            end
        end;
        TryAddNewUsedName = function (this, type, newName) 
            local set = CSharpLua.Utility.GetOrDefault1(this.typeNameUseds_, type, nil, Microsoft.CodeAnalysis.INamedTypeSymbol, System.HashSet(T));
            if set == nil then
                set = System.HashSet(System.String)();
                this.typeNameUseds_:Add(type, set);
            end
            return set:Add(newName);
        end;
        GetSameNameMembers = function (this, symbol) 
            local members = System.List(Microsoft.CodeAnalysis.ISymbol)();
            FillSameNameMembers(this, symbol:getContainingType(), symbol:getName(), members);
            members:Sort(MemberSymbolComparison);
            return members;
        end;
        MethodSymbolToString = function (this, symbol) 
            local sb = System.StringBuilder();
            sb:Append(symbol:getName());
            sb:Append(40 --[['(']]);
            local isFirst = true;
            for _, p in System.each(symbol:getParameters()) do
                if isFirst then
                    isFirst = false;
                else
                    sb:Append(",");
                end
                sb:Append(p:getType():ToString());
            end
            sb:Append(41 --[[')']]);
            return sb:ToString();
        end;
        MemberSymbolToString = function (this, symbol) 
            if symbol:getKind() == 9 --[[SymbolKind.Method]] then
                return MethodSymbolToString(this, System.cast(Microsoft.CodeAnalysis.IMethodSymbol, symbol));
            else
                return symbol:getName();
            end
        end;
        GetSymbolWright = function (this, symbol) 
            if symbol:getKind() == 9 --[[SymbolKind.Method]] then
                local methodSymbol = System.cast(Microsoft.CodeAnalysis.IMethodSymbol, symbol);
                return methodSymbol:getParameters():getLength();
            else
                return 0;
            end
        end;
        MemberSymbolCommonComparison = function (this, a, b) 
            local weightOfA = GetSymbolWright(this, a);
            local weightOfB = GetSymbolWright(this, b);
            if weightOfA ~= weightOfB then
                return weightOfA:CompareTo(weightOfB);
            else
                local nameOfA = MemberSymbolToString(this, a);
                local nameOfB = MemberSymbolToString(this, b);
                return nameOfA:CompareTo(nameOfB);
            end
        end;
        MemberSymbolBoolComparison = function (this, a, b, boolFunc, v) 
            local boolOfA = boolFunc(this, a);
            local boolOfB = boolFunc(this, b);

            if boolOfA then
                if boolOfB then
                    v = MemberSymbolCommonComparison(this, a, b);
                else
                    v = - 1;
                end
                return true;
            end

            if b:getIsAbstract() then
                v = 1;
                return true;
            end

            v = 0;
            return false;
        end;
        MemberSymbolComparison = function (this, a, b) 
            local isFromCodeOfA = CSharpLua.Utility.IsFromCode(a:getContainingType());
            local isFromCodeOfB = CSharpLua.Utility.IsFromCode(b:getContainingType());

            if not isFromCodeOfA then
                if not isFromCodeOfB then
                    return 0;
                else
                    return - 1;
                end
            end

            if not isFromCodeOfB then
                return 1;
            end

            local countOfA = Linq.Count(CSharpLua.Utility.InterfaceImplementations(a, Microsoft.CodeAnalysis.ISymbol));
            local countOfB = Linq.Count(CSharpLua.Utility.InterfaceImplementations(b, Microsoft.CodeAnalysis.ISymbol));
            if countOfA > 0 or countOfB > 0 then
                if countOfA ~= countOfB then
                    return countOfA > countOfB and - 1 or 1;
                else
                    return MemberSymbolCommonComparison(this, a, b);
                end
            end

            local v;
            local default;
            default, v = MemberSymbolBoolComparison(this, a, b, function (i) return i:getIsAbstract(); end, v);
            if default then
                return v;
            end
            local extern;
            extern, v = MemberSymbolBoolComparison(this, a, b, function (i) return i:getIsVirtual(); end, v);
            if extern then
                return v;
            end
            local ref;
            ref, v = MemberSymbolBoolComparison(this, a, b, function (i) return i:getIsOverride(); end, v);
            if ref then
                return v;
            end

            if a:getContainingType():Equals(b:getContainingType()) then
                local name = a:getName();
                local type = a:getContainingType();
                local members = type:GetMembers(name);
                local indexOfA = members:IndexOf(a);
                assert(indexOfA ~= - 1);
                local indexOfB = members:IndexOf(b);
                assert(indexOfB ~= - 1);
                assert(indexOfA ~= indexOfB);
                return indexOfA:CompareTo(indexOfB);
            else
                local isSubclassOf = CSharpLua.Utility.IsSubclassOf(a:getContainingType(), b:getContainingType());
                return isSubclassOf and 1 or - 1;
            end
        end;
        FillSameNameMembers = function (this, typeSymbol, name, outList) 
            if typeSymbol:getBaseType() ~= nil then
                FillSameNameMembers(this, typeSymbol:getBaseType(), name, outList);
            end

            local isFromCode = CSharpLua.Utility.IsFromCode(typeSymbol);
            local members = typeSymbol:GetMembers(name);
            for _, member in System.each(members) do
                local continue;
                repeat
                    if not isFromCode then
                        if member:getDeclaredAccessibility() == 1 --[[Accessibility.Private]] or member:getDeclaredAccessibility() == 4 --[[Accessibility.Internal]] then
                            continue = true;
                            break;
                        end
                    end

                    if member:getIsOverride() then
                        continue = true;
                        break;
                    end

                    outList:Add(member);
                    continue = true;
                until 1;
                if not continue then
                    break;
                end
            end
        end;
        CheckRefactorNames = function (this) 
            local alreadyRefactorSymbols = System.HashSet(Microsoft.CodeAnalysis.ISymbol)();

            for _, symbol in System.each(this.refactorNames_) do
                local hasImplementation = false;
                for _, implementation in System.each(CSharpLua.Utility.InterfaceImplementations(symbol, Microsoft.CodeAnalysis.ISymbol)) do
                    RefactorInterfaceSymbol(this, implementation, alreadyRefactorSymbols);
                    hasImplementation = true;
                end

                if not hasImplementation then
                    RefactorCurTypeSymbol(this, symbol, alreadyRefactorSymbols);
                end
            end
        end;
        RefactorCurTypeSymbol = function (this, symbol, alreadyRefactorSymbols) 
            local typeSymbol = symbol:getContainingType();
            local childrens = CSharpLua.Utility.GetOrDefault1(this.extends_, typeSymbol, nil, Microsoft.CodeAnalysis.INamedTypeSymbol, System.HashSet(T));
            local newName = GetRefactorName(this, typeSymbol, childrens, symbol:getName());
            RefactorName(this, symbol, newName, alreadyRefactorSymbols);
        end;
        RefactorInterfaceSymbol = function (this, symbol, alreadyRefactorSymbols) 
            if CSharpLua.Utility.IsFromCode(symbol) then
                local typeSymbol = symbol:getContainingType();
                assert(typeSymbol:getTypeKind() == 7 --[[TypeKind.Interface]]);
                local childrens = this.extends_:get(typeSymbol);
                local newName = GetRefactorName(this, nil, childrens, symbol:getName());
                for _, children in System.each(childrens) do
                    local childrenSymbol = children:FindImplementationForInterfaceMember(symbol);
                    assert(childrenSymbol ~= nil);
                    RefactorName(this, childrenSymbol, newName, alreadyRefactorSymbols);
                end
            end
        end;
        RefactorName = function (this, symbol, newName, alreadyRefactorSymbols) 
            if not alreadyRefactorSymbols:Contains(symbol) then
                if CSharpLua.Utility.IsOverridable(symbol) then
                    RefactorChildrensOverridden(this, symbol, symbol:getContainingType(), newName, alreadyRefactorSymbols);
                end
                UpdateName(this, symbol, newName, alreadyRefactorSymbols);
            end
        end;
        RefactorChildrensOverridden = function (this, originalSymbol, curType, newName, alreadyRefactorSymbols) 
            local childrens = CSharpLua.Utility.GetOrDefault1(this.extends_, curType, nil, Microsoft.CodeAnalysis.INamedTypeSymbol, System.HashSet(T));
            if childrens ~= nil then
                for _, children in System.each(childrens) do
                    local curSymbol = System.Linq.ImmutableArrayExtensions.FirstOrDefault(children:GetMembers(originalSymbol:getName()), function (i) return CSharpLua.Utility.IsOverridden(i, originalSymbol); end, Microsoft.CodeAnalysis.ISymbol);
                    if curSymbol ~= nil then
                        UpdateName(this, curSymbol, newName, alreadyRefactorSymbols);
                    end
                    RefactorChildrensOverridden(this, originalSymbol, children, newName, alreadyRefactorSymbols);
                end
            end
        end;
        UpdateName = function (this, symbol, newName, alreadyRefactorSymbols) 
            this.memberNames_:get(symbol):Update(newName);
            TryAddNewUsedName(this, symbol:getContainingType(), newName);
            alreadyRefactorSymbols:Add(symbol);
        end;
        GetRefactorName = function (this, typeSymbol, childrens, originalName) 
            local index = 1;
            while true do
                local newName = (originalName or "") .. index;
                local isEnable = true;
                if typeSymbol ~= nil then
                    isEnable = CheckNewNameEnable(this, typeSymbol, newName);
                end

                if isEnable then
                    if childrens ~= nil then
                        isEnable = Linq.All(childrens, function (i) return CheckNewNameEnable(this, i, newName); end);
                    end
                end

                if isEnable then
                    return newName;
                end
                index = index + 1;
            end
        end;
        IsTypeNameUsed = function (this, typeSymbol, newName) 
            local set = CSharpLua.Utility.GetOrDefault1(this.typeNameUseds_, typeSymbol, nil, Microsoft.CodeAnalysis.INamedTypeSymbol, System.HashSet(T));
            return set ~= nil and set:Contains(newName);
        end;
        CheckNewNameEnable = function (this, typeSymbol, newName) 
            if typeSymbol:GetMembers(newName):getIsEmpty() then
                if IsTypeNameUsed(this, typeSymbol, newName) then
                    return false;
                end
            end

            local childrens = CSharpLua.Utility.GetOrDefault1(this.extends_, typeSymbol, nil, Microsoft.CodeAnalysis.INamedTypeSymbol, System.HashSet(T));
            if childrens ~= nil then
                for _, children in System.each(childrens) do
                    if not CheckNewNameEnable(this, children, newName) then
                        return false;
                    end
                end
            end

            return true;
        end;
        __init__ = function (this) 
            this.exportEnums_ = System.HashSet(System.String)();
            this.enumDeclarations_ = System.List(CSharpLua.LuaAst.LuaEnumDeclarationSyntax)();
            this.partialTypes_ = System.Dictionary(Microsoft.CodeAnalysis.INamedTypeSymbol, System.List(CSharpLua.PartialTypeDeclaration))();
            this.memberNames_ = System.Dictionary(Microsoft.CodeAnalysis.ISymbol, CSharpLua.LuaAst.LuaSymbolNameSyntax)();
            this.typeNameUseds_ = System.Dictionary(Microsoft.CodeAnalysis.INamedTypeSymbol, System.HashSet(System.String))();
            this.refactorNames_ = System.HashSet(Microsoft.CodeAnalysis.ISymbol)();
            this.extends_ = System.Dictionary(Microsoft.CodeAnalysis.INamedTypeSymbol, System.HashSet(Microsoft.CodeAnalysis.INamedTypeSymbol))();
            this.types_ = System.List(Microsoft.CodeAnalysis.INamedTypeSymbol)();
        end;
        __ctor__ = function (this, metas, compilation) 
            __init__(this);
            this.XmlMetaProvider = CSharpLua.XmlMetaProvider(metas);
            this.Setting = CSharpLua.LuaSyntaxGenerator.SettingInfo();
            this.compilation_ = compilation;
        end;
        return {
            Generate = Generate, 
            IsEnumExport = IsEnumExport, 
            AddExportEnum = AddExportEnum, 
            AddEnumDeclaration = AddEnumDeclaration, 
            AddPartialTypeDeclaration = AddPartialTypeDeclaration, 
            GetSemanticModel = GetSemanticModel, 
            IsBaseType = IsBaseType, 
            GetMethodName = GetMethodName, 
            AddTypeSymbol = AddTypeSymbol, 
            GetMemberMethodName = GetMemberMethodName, 
            __ctor__ = __ctor__
        };
    end);
end);
