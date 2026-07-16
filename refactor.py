import re

def process_file(filepath, is_supplier):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Revert bad edit if it exists
    content = re.sub(
        r'_RoleToggle\(\s*isLogin: true,\s*onSwitchRole: widget\.onSwitchRole,\s*\)',
        r'_RoleToggle(isLogin: true)',
        content
    )

    # 1. Add onSwitchRole to main screen constructor
    content = re.sub(
        r'(required this\.onComplete,)(\s*}\);)',
        r'\1\n    required this.onSwitchRole,\n\2',
        content, count=1
    )
    
    # 2. _LoginView constructor
    content = re.sub(
        r'(required this\.onLoginSuccess,)(\s*}\);)',
        r'\1\n    required this.onSwitchRole,\n\2',
        content, count=1
    )
    content = re.sub(
        r'(final VoidCallback onLoginSuccess;)(\s*const _LoginView\()',
        r'\1\n  final VoidCallback onSwitchRole;\n\2',
        content, count=1
    )
    
    # 3. _SignUpView constructor
    content = re.sub(
        r'(required this\.onBackToLanding,)(\s*}\);)',
        r'\1\n    required this.onSwitchRole,\n\2',
        content, count=1
    )
    content = re.sub(
        r'(final VoidCallback onBackToLanding;)(\s*const _SignUpView\()',
        r'\1\n  final VoidCallback onSwitchRole;\n\2',
        content, count=1
    )
    
    # 4. _buildCurrentFormView instantiations
    content = re.sub(
        r'(onLoginSuccess: widget\.onComplete,)(\s*\);)',
        r'\1\n          onSwitchRole: widget.onSwitchRole,\n\2',
        content
    )
    content = re.sub(
        r'(onBackToLanding: widget\.onBackToLanding,)(\s*\);)',
        r'\1\n          onSwitchRole: widget.onSwitchRole,\n\2',
        content
    )
    
    # 5. _RoleToggle instantiations
    content = re.sub(
        r'_RoleToggle\(isLogin: (true|false|_isLogin)\)',
        r'_RoleToggle(isLogin: \1, onSwitchRole: widget.onSwitchRole)',
        content
    )
    
    # 6. _RoleToggle constructor
    content = re.sub(
        r'(final bool isLogin;)\n\s*(final VoidCallback onSwitchRole;)?\n\s*const _RoleToggle\(\{required this\.isLogin(?:, required this\.onSwitchRole)?\}\);',
        r'\1\n  final VoidCallback onSwitchRole;\n  const _RoleToggle({super.key, required this.isLogin, required this.onSwitchRole});',
        content
    )
    
    # 7. Wrap with GestureDetector
    if is_supplier:
        content = re.sub(
            r"(Expanded\(\s*child: )Container\(\s*alignment: Alignment\.center,\s*child: Text\(\s*'NGO Partner'",
            r"\1GestureDetector(onTap: onSwitchRole, child: Container(alignment: Alignment.center, child: Text('NGO Partner'",
            content
        )
        content = content.replace("GestureDetector(onTap: onSwitchRole, child: GestureDetector(onTap: onSwitchRole,", "GestureDetector(onTap: onSwitchRole,")
        content = content.replace("), // text NGO Partner\n              ), // Container\n            ), // Expanded\n          ),", "),),),),")
        content = re.sub(r"'NGO Partner',\s*style: GoogleFonts\.inter\([\s\S]*?\),\s*\),\s*\),\s*\),", r"\g<0>\n)", content)
    else:
        content = re.sub(
            r"(Expanded\(\s*child: )Container\(\s*alignment: Alignment\.center,\s*child: Text\(\s*'Supplier'",
            r"\1GestureDetector(onTap: onSwitchRole, child: Container(alignment: Alignment.center, child: Text('Supplier'",
            content
        )
        content = re.sub(
            r"(Expanded\(\s*child: )Container\(\s*decoration: BoxDecoration\([\s\S]*?\),\s*alignment: Alignment\.center,\s*child: Text\(\s*'Supplier'",
            r"\1GestureDetector(onTap: onSwitchRole, child: Container(alignment: Alignment.center, child: Text('Supplier'",
            content
        )

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

process_file('lib/features/auth/screens/supplier_auth_ui_flow_screen.dart', True)
process_file('lib/features/auth/screens/ngo_auth_ui_flow_screen.dart', False)
print('Done!')
