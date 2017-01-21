﻿-- Generated by CSharp.lua Compiler 1.0.0.0
local System = System;
System.namespace("CSharpLua.LuaAst", function (namespace) 
    namespace.class("LuaWrapFunctionStatementSynatx", function (namespace) 
        local UpdateIdentifiers, AddMemberDeclaration, Render, __ctor__;
        UpdateIdentifiers = function (this, name, target, memberName, parameter) 
            local memberAccess = CSharpLua.LuaAst.LuaMemberAccessExpressionSyntax(target, memberName);
            local invoke = CSharpLua.LuaAst.LuaInvocationExpressionSyntax:new(1, memberAccess);
            invoke:AddArgument(CSharpLua.LuaAst.LuaStringLiteralExpressionSyntax:new(1, name));
            invoke:AddArgument(this.function_);
            if parameter ~= nil then
                this.function_:AddParameter(parameter);
            end
            this.Statement = CSharpLua.LuaAst.LuaExpressionStatementSyntax(invoke);
        end;
        AddMemberDeclaration = function (this, statement) 
            if statement == nil then
                System.throw(System.ArgumentNullException("statement"));
            end
            this.statements_:Add(statement);
        end;
        Render = function (this, renderer) 
            this.function_:AddStatements(this.statements_);
            renderer:Render1(this);
        end;
        __ctor__ = function (this) 
            this.function_ = CSharpLua.LuaAst.LuaFunctionExpressionSyntax();
            this.statements_ = System.List(CSharpLua.LuaAst.LuaStatementSyntax)();
        end;
        return {
            __inherits__ = {
                CSharpLua.LuaAst.LuaStatementSyntax
            }, 
            UpdateIdentifiers = UpdateIdentifiers, 
            AddMemberDeclaration = AddMemberDeclaration, 
            Render = Render, 
            __ctor__ = __ctor__
        };
    end);
end);
