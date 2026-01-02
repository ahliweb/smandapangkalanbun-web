
import React from 'react';
import { Link } from 'react-router-dom';
import GenericContentManager from '@/components/dashboard/GenericContentManager';
import { Mail, ChevronRight, Home } from 'lucide-react';

function ContactMessagesManager() {
    const columns = [
        { key: 'name', label: 'Sender' },
        { key: 'subject', label: 'Subject' },
        { key: 'created_at', label: 'Date', type: 'date' },
        {
            key: 'status',
            label: 'Status',
            render: (value) => (
                <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${value === 'new' ? 'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400' :
                    value === 'replied' ? 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400' :
                        'bg-muted text-muted-foreground'
                    }`}>
                    {value || 'new'}
                </span>
            )
        }
    ];

    const formFields = [
        { key: 'status', label: 'Status', type: 'select', options: [{ value: 'new', label: 'New' }, { value: 'read', label: 'Read' }, { value: 'replied', label: 'Replied' }] }
    ];

    return (
        <div className="space-y-6">
            {/* Breadcrumb Navigation */}
            <nav className="flex items-center text-sm text-muted-foreground">
                <Link to="/cmspanel" className="hover:text-primary transition-colors flex items-center gap-1">
                    <Home className="w-4 h-4" />
                    Dashboard
                </Link>
                <ChevronRight className="w-4 h-4 mx-2 text-muted-foreground/50" />
                <span className="flex items-center gap-1 text-foreground font-medium">
                    <Mail className="w-4 h-4" />
                    Contact Messages
                </span>
            </nav>

            <GenericContentManager
                tableName="contact_messages"
                resourceName="Message"
                columns={columns}
                formFields={formFields}
                permissionPrefix="contact_messages"
                showBreadcrumbs={false}
            />
        </div>
    );
}

export default ContactMessagesManager;
